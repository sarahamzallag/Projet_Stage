import matplotlib.pyplot as plt
from matplotlib_venn import venn3
import os

# --- 1. CONFIGURATION ---
mapping_file = "/home/amzallag/stage/script/groupe.tsv"
genecount_file = "/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv"
output_image = "/home/amzallag/stage/Figures/venn2.png"

# --- 2. CHARGEMENT DU MAPPING ---
groups = {}
with open(mapping_file, 'r') as f:
    next(f) 
    for line in f:
        parts = line.strip().split('\t')
        if len(parts) >= 2:
            groups[parts[0]] = parts[1]

# --- 3. ANALYSE DU FICHIER GENECOUNT ---
diplo_sets = set()
chilo_sets = set()
autres_sets = set()

with open(genecount_file, 'r') as f:
    header = f.readline().strip().split('\t')
    col_to_group = {}
    for i, col_name in enumerate(header):
        for species, group_name in groups.items():
            if species in col_name:
                col_to_group[i] = group_name

    for line in f:
        parts = line.strip().split('\t')
        og_id = parts[0]
        
        # Filtre : compte espèces possédant au moins 1 gène (exclut ID et Total)
        species_count = sum(1 for count in parts[1:-1] if int(count) > 0)

        if species_count >= 2:
            has_diplo = has_chilo = has_autres = False
            for i, count in enumerate(parts[1:-1], 1):
                if i in col_to_group and int(count) > 0:
                    group = col_to_group[i]
                    if group == "Diplopoda": has_diplo = True
                    elif group == "Chilopoda": has_chilo = True
                    else: has_autres = True

            if has_diplo: diplo_sets.add(og_id)
            if has_chilo: chilo_sets.add(og_id)
            if has_autres: autres_sets.add(og_id)

# --- 4. DESSIN DU VENN ---
plt.figure(figsize=(12, 10))
v = venn3([diplo_sets, chilo_sets, autres_sets], 
          set_labels=('Diplopoda', 'Chilopoda', 'Others'))

# Style des chiffres
for text in v.subset_labels:
    if text:
        text.set_fontsize(12)
        text.set_fontweight('bold')

# Couleurs
colors = ['#ff9999', '#66b3ff', '#99ff99']
for i, p_id in enumerate(['100', '010', '001']):
    if v.get_patch_by_id(p_id):
        v.get_patch_by_id(p_id).set_color(colors[i])
        v.get_patch_by_id(p_id).set_alpha(0.5)

plt.title("Conservation of gene families (Orthogroups)\n[Filtered: Shared by at least 2 species]", 
          fontsize=14, fontweight='bold', pad=30)

# Total et légende (Correction transform)
total_og = len(diplo_sets | chilo_sets | autres_sets)
plt.text(0.5, -0.05, f'Total analyzed Orthogroups (shared): {total_og}', 
         ha='center', va='center', transform=plt.gca().transAxes, 
         fontsize=11, style='italic')

# --- 5. SAUVEGARDE ---
os.makedirs(os.path.dirname(output_image), exist_ok=True)
plt.savefig(output_image, dpi=300, bbox_inches='tight')
print(f"Terminé ! L'image est ici : {output_image}")