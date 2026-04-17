import pandas as pd
import matplotlib.pyplot as plt

# 1. CONFIGURATION DES CHEMINS
INPUT_FILE = "/home/amzallag/stage/result_cascade.tsv"
OUTPUT_FILE = "/home/amzallag/stage/Figures/graphique_cascade_final.png"

groupes_config = [
    ("Chelicerata", ["ixodes", "argiope", "centruroides", "tachypleus"], "#d4ac0d"),
    ("Chilopoda", ["pachymerium", "acuminata", "maritima", "variegatus", "immarginata", "cretica"], "#27ae60"),
    ("Diplopoda", ["nanogona", "choneiulus", "cylindroiulus", "julidae", "brachycybe", "polydesmus", "agaricogonopus", "trigoniulus"], "#16a085"),
    ("Crustacea", ["daphnia", "amphitrite", "eriocheir", "trigriopus"], "#2980b9"),
    ("Hexapoda", ["folsomia", "drosophila", "padi", "gregaria", "ischnura"], "#8e44ad")
]

labels_legende = {
    'PROT_100a': 'Arthropod core (100%)',
    'PROT_75a': 'Arthropod shared (≥75%)',
    'PROT_100g': 'Subphylum core (100%)',
    'PROT_75g': 'Subphylum shared (≥75%)',
    'PROT_100m': 'Diplopod or Chilopod core (100%)',
    'PROT_75m': 'Diplopod or Chilopod shared (≥75%)',
    'PROT_autre': 'Other',
    'PROT_spec': 'Species-specific'
}

# 2. CHARGEMENT ET NETTOYAGE
df = pd.read_csv(INPUT_FILE, sep='\t')

final_data = []
row_colors = []
for nom_grp, keywords, color in groupes_config:
    for kw in keywords:
        # Recherche dans la colonne 'Species'
        match = df[df['Species'].str.contains(kw, case=False)]
        if not match.empty:
            row = match.iloc[0].copy()
            
            # --- FORCEAGE JULIDAE OU NETTOYAGE CLASSIQUE ---
            if "julidae" in row['Species'].lower():
                row['Species'] = "Julidae sp. JJ-2019"
            else:
                clean_name = row['Species'].replace('_', '-').split('-')
                row['Species'] = f"{clean_name[0].capitalize()} {clean_name[1]}"
            # -----------------------------------------------
            
            final_data.append(row)
            row_colors.append(color)

# On définit l'index sur 'Species'
df_plot = pd.DataFrame(final_data).set_index('Species')
cols_prot = list(labels_legende.keys())
df_final = df_plot[cols_prot]

# 3. DESSIN
fig, ax = plt.subplots(figsize=(22, 11)) 

couleurs_finales = ['#08306b','#4292c6','#fe9929','#fec44f','#006d2c','#74c476','#91a3b0','#DE3163']

df_final.plot(kind='barh', stacked=True, color=couleurs_finales, ax=ax, width=0.7, edgecolor='white', linewidth=0.2)
ax.grid(axis='x', linestyle='--', alpha=0.4, color='gray', zorder=0)

# ACCROCHAGE DES GROUPES
current_idx = 0
max_val = df_final.sum(axis=1).max()
marge_gauche = max_val * 0.35 

for nom_grp, keywords, color in groupes_config:
    nb_sp = len([k for k in keywords if any(k in idx.lower() for idx in df_plot.index)])
    if nb_sp > 0:
        y_start = current_idx - 0.3
        y_end = current_idx + nb_sp - 0.7
        x_pos_line = -marge_gauche 
        ax.plot([x_pos_line, x_pos_line], [y_start, y_end], color=color, linewidth=8, clip_on=False)
        ax.text(x_pos_line - (max_val * 0.02), (y_start + y_end)/2, nom_grp, color=color, fontweight='bold', ha='right', va='center', fontsize=14)
        current_idx += nb_sp

ax.invert_yaxis()
ax.set_xlim(left=0) 
ax.tick_params(axis='y', pad=45)

for tick, color in zip(ax.get_yticklabels(), row_colors):
    tick.set_color(color)
    tick.set_fontstyle('italic')

ax.set_xlabel('Number of proteins', fontsize=12, fontweight='bold')
ax.set_title('Evolution of gene content in Arthropoda', fontsize=18, pad=35)
handles, _ = ax.get_legend_handles_labels()
ax.legend(handles, labels_legende.values(), bbox_to_anchor=(1.02, 1), loc='upper left', frameon=False)

plt.tight_layout()
plt.savefig(OUTPUT_FILE, dpi=300, bbox_inches='tight')
print(f"Succès ! Le graphique est ici : {OUTPUT_FILE}")