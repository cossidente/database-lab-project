from pathlib import Path

import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


ROOT_DIR = Path(__file__).parent.parent


x = np.linspace(0, 800000, 1000)


cost_a = 1650000 + 2 * x
cost_b = 50000 + 4.4 * x

break_even = 1600000 / 2.4
break_even_cost = 1650000 + 2 * break_even

df = pd.DataFrame(
    {
        "Scritture annue": np.concatenate([x, x]),
        "Accessi annui": np.concatenate([cost_a, cost_b]),
        "Strategia": ["A (no ridondanza)"] * len(x) + ["B (ridondanza)"] * len(x),
    }
)

sns.set_theme(style="whitegrid")

plt.figure(figsize=(10, 6))

sns.lineplot(
    data=df, x="Scritture annue", y="Accessi annui", hue="Strategia", linewidth=2.5
)

plt.scatter(
    break_even,
    break_even_cost,
    s=100,
    zorder=5,
    label=f"Break-even ({break_even:,.0f})",
)

plt.axvline(80000, linestyle="--", linewidth=2, label="Carico stimato (80.000)")

plt.xlabel("Numero di registrazioni esami annue")
plt.ylabel("Costo totale (accessi annui)")
plt.title("Analisi di scalabilità della ridondanza")
plt.ylim(top=max(cost_a.max(), cost_b.max()) * 1.1)
plt.legend(loc="upper left", fontsize=10)

plt.tight_layout()
plt.savefig(ROOT_DIR / "plots" / "redundancy_analysis.pdf")
