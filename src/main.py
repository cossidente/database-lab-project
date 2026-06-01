from sqlalchemy import create_engine, MetaData, insert
from faker import Faker
import json
import string
import random
from datetime import date, timedelta

PERIODS = ["1", "2", "3"]
ROOMS = ["Aula 1", "Aula Magna", "Laboratorio A", "Aula 2", "Laboratorio B"]
WEEKDAYS = ["Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì"]
TIMESLOTS = ["1", "2", "3", "4"]
ACADEMIC_YEARS = ["2023/2024", "2024/2025", "2025/2026"]
ENROLLMENT_YEARS = [2020, 2021, 2022, 2023, 2024, 2025]
POSITIONS = ['Professore ordinario', 'Professore associato', 'Ricercatore']

def load_json(filename):
    with open(f"data/{filename}", "r", encoding="utf-8") as f:
        return json.load(f)


def add_courses(engine, metadata, fake):
    courses = load_json("courses.json")

    for course in courses:
        description = fake.paragraph(nb_sentences=2)
        course["descrizione"] = f"Corso di {course['nome']}. {description}"

    bulk_insert(engine, metadata.tables['corso'], courses)

def add_editions(engine, metadata):
    # Get all courses
    with engine.connect() as conn:
        courses = conn.execute(metadata.tables['corso'].select()).fetchall()
    
    editions = []
    
    for course in courses:
        num_editions = random.randint(1, len(ACADEMIC_YEARS))
        selected_years = random.sample(ACADEMIC_YEARS, num_editions) # Without repetitions
        
        for ay in selected_years:
            editions.append({
                "codice_corso": course.codice,
                "anno_accademico": ay,
                "periodo": random.choice(PERIODS)
            })
    
    bulk_insert(engine, metadata.tables['edizione'], editions)

def add_lectures(engine, metadata):
    with engine.connect() as conn:
        editions = conn.execute(metadata.tables['edizione'].select()).fetchall()
    
    lectures = []
    occupied_slots = set()
    
    for edition in editions:
        lectures_assigned = 0
        max_attempts = 50 # Safeguard to prevent infinite loops if rooms run out
        
        # Try to assign exactly 2 lectures per edition
        while lectures_assigned < 2 and max_attempts > 0:
            day = random.choice(WEEKDAYS)
            slot = random.choice(TIMESLOTS)
            room = random.choice(ROOMS)
            
            # The unique signature of this specific lesson slot
            slot_signature = (edition.anno_accademico, edition.periodo, day, slot, room)
            
            # Check if the room is already taken at that specific time
            if slot_signature not in occupied_slots:
                occupied_slots.add(slot_signature) # Mark as occupied
                
                lectures.append({
                    "codice_corso": edition.codice_corso,
                    "anno_accademico": edition.anno_accademico,
                    "periodo": edition.periodo,
                    "giorno": day,
                    "fascia_oraria": slot,
                    "aula": room
                })
                lectures_assigned += 1
                
            max_attempts -= 1
            
    bulk_insert(engine, metadata.tables['lezione'], lectures)


def generate_cf():
    part1 = ''.join(random.choices(string.ascii_uppercase, k=6))
    part2 = ''.join(random.choices(string.digits, k=2))
    part3 = random.choice(string.ascii_uppercase)
    part4 = ''.join(random.choices(string.digits, k=2))
    part5 = random.choice(string.ascii_uppercase)
    part6 = ''.join(random.choices(string.digits, k=3))
    part7 = random.choice(string.ascii_uppercase)
    return f"{part1}{part2}{part3}{part4}{part5}{part6}{part7}"

def add_teachers(n, engine, metadata, fake):
    teachers = []
    
    # Get all departments codes
    with engine.connect() as conn:
        result = conn.execute(metadata.tables['dipartimento'].select())
        department_codes = [row[0] for row in result]
    
    for _ in range(n):
        teachers.append({
            "cf": generate_cf(),
            "nome": fake.first_name(),
            "cognome": fake.last_name(),
            "titolo": random.choice(POSITIONS),
            "dipartimento": random.choice(department_codes)
        })

    bulk_insert(engine, metadata.tables['docente'], teachers)

def add_teacher_qualifications(engine, metadata):
    # Get all teachers and courses to create random associations
    with engine.connect() as conn:
        teachers = conn.execute(metadata.tables['docente'].select()).fetchall()
        courses = conn.execute(metadata.tables['corso'].select()).fetchall()
    
    qualifications = []
    # Assign each to teacher 1-3 random courses they are "qualified" for
    for teacher in teachers:
        num_courses = random.randint(1, 3)
        assigned_courses = random.sample(courses, num_courses)
        for course in assigned_courses:
            qualifications.append({
                "cf_docente": teacher.cf,
                "codice_corso": course.codice
            })
            
    bulk_insert(engine, metadata.tables['abilitazione_docente_corso'], qualifications)

def add_editions_teachings(engine, metadata):
    # Get qualifications and editions to consider only qualified teachers
    with engine.connect() as conn:
        qualifications = conn.execute(metadata.tables['abilitazione_docente_corso'].select()).fetchall()
        editions = conn.execute(metadata.tables['edizione'].select()).fetchall()
    
    # Build a dict: course_code -> list of qualified teacher CFs
    qualified_teachers_map = {}
    for q in qualifications:
        if q.codice_corso not in qualified_teachers_map:
            qualified_teachers_map[q.codice_corso] = []
        qualified_teachers_map[q.codice_corso].append(q.cf_docente)
        
    teachings = []
    
    for edition in editions:
        # Get only the teachers qualified for this specific course
        available_teachers = qualified_teachers_map.get(edition.codice_corso, [])
        
        # If no one is qualified, we must skip to avoid DB constraints violation
        if not available_teachers:
            continue 
            
        # Safely pick 1 or 2 teachers, avoiding errors if only 1 is available
        num_teachers = min(random.randint(1, 2), len(available_teachers))
        assigned_teachers = random.sample(available_teachers, num_teachers)
        
        for teacher_cf in assigned_teachers:
            teachings.append({
                "cf_docente": teacher_cf,
                "codice_corso": edition.codice_corso,
                "anno_accademico": edition.anno_accademico,
                "periodo": edition.periodo
            })
            
    bulk_insert(engine, metadata.tables['insegnamento_edizione'], teachings)


def add_students(n, engine, metadata, fake):
    students = []
    
    # Get all degree programs codes
    with engine.connect() as conn:
        result = conn.execute(metadata.tables['corso_di_laurea'].select())
        degree_program = [row[0] for row in result]
    
    for _ in range(n):
        year = random.choice(ENROLLMENT_YEARS)
        ay = f"{year}/{year + 1}"
        
        students.append({
            "nome": fake.first_name(),
            "cognome": fake.last_name(),
            "telefono": fake.numerify(text="3#########"),
            "aa_immatricolazione": ay,
            "corso_di_laurea": random.choice(degree_program),
            "crediti_acquisiti": 0
        })

    bulk_insert(engine, metadata.tables['studente'], students)

def add_study_plans(engine, metadata):
    # Get all students and all courses
    with engine.connect() as conn:
        students = conn.execute(metadata.tables['studente'].select()).fetchall()
        courses = conn.execute(metadata.tables['corso'].select()).fetchall()
    
    study_plans = []
    
    for student in students:
        num_courses = random.randint(5, 10) # num courses in the study plan
        
        selected_courses = random.sample(courses, num_courses)
        
        for course in selected_courses:
            study_plans.append({
                "matricola": student.matricola,
                "codice_corso": course.codice
            })
            
    bulk_insert(engine, metadata.tables['piano_di_studio'], study_plans)


def add_exams(engine, metadata):
    # Get all students and their study plans
    with engine.connect() as conn:
        students = conn.execute(metadata.tables['studente'].select()).fetchall()
        study_plans = conn.execute(metadata.tables['piano_di_studio'].select()).fetchall()

    # Build a dict: matricola -> courses in the study plan
    student_courses_map = {}
    for study_plan in study_plans:
        if study_plan.matricola not in student_courses_map:
            student_courses_map[study_plan.matricola] = []
        student_courses_map[study_plan.matricola].append(study_plan.codice_corso)

    exams_to_insert = []

    for student in students:
        courses_in_study_plan = student_courses_map.get(student.matricola, [])
        
        if not courses_in_study_plan:
            continue

        num_exams = random.randint(1, len(courses_in_study_plan))
        taken_exams = random.sample(courses_in_study_plan, num_exams)

        for exam in taken_exams:
            date = get_random_past_date()
            score = random.randint(0, 30)

            exams_to_insert.append({
                "matricola": student.matricola,
                "codice_corso": exam,
                "data_esame": date,
                "punteggio": score
            })
    
    bulk_insert(engine, metadata.tables['esame'], exams_to_insert)

def get_random_past_date(start_year=2020):
    start_date = date(start_year, 1, 1)
    end_date = date.today()
    
    days_between = (end_date - start_date).days
    
    random_days = random.randint(0, days_between)
    return start_date + timedelta(days=random_days)


def bulk_insert(engine, table, data):
    if not data:
        print(f"Skipped insert into {table.name}: no rows to insert.")
        return
    
    try:
        with engine.begin() as conn:
            conn.execute(insert(table), data)
            print(f"Inserted {len(data)} record in {table.name}.")
    except Exception as e:
        print(f"Error while inserting in {table.name}: {e}")


def main():
    # Config
    DATABASE_URL = "postgresql://admin:password@localhost:5432/21-database-lab-project"
    engine = create_engine(DATABASE_URL)
    metadata = MetaData()
    metadata.reflect(bind=engine)

    fake = Faker('it_IT')

    # Adding accessory data
    bulk_insert(engine, metadata.tables['dipartimento'], load_json("departments.json"))
    bulk_insert(engine, metadata.tables['corso_di_laurea'], load_json("degree_programs.json"))

    # Adding courses, their prerequisites, editions and lectures
    add_courses(engine, metadata, fake)
    bulk_insert(engine, metadata.tables['prerequisito'], load_json("prerequisites.json"))
    add_editions(engine, metadata)
    add_lectures(engine, metadata)

    # Adding teachers, their qualifications for teaching and the actual teaching for editions
    add_teachers(20, engine, metadata, fake)
    add_teacher_qualifications(engine, metadata)
    add_editions_teachings(engine, metadata)

    # Adding students and their study plans
    add_students(50, engine, metadata, fake)
    add_study_plans(engine, metadata)

    # Adding taken exams
    add_exams(engine, metadata)

if __name__ == "__main__":
    main()
