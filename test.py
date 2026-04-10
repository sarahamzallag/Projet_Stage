import pandas as pd
import matplotlib.pyplot as plt

# Chemin du fichier OrthoFinder
file = "/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv"

# Chemin du fichier contenant les groupes d'espèces
chemin_espece = "/home/amzallag/stage/script/especes.tsv"

# Lecture des fichiers
tableau = pd.read_csv(file, sep="\t")  # lire le fichier GeneCount
groupes = pd.read_csv(chemin_espece, sep="\t")  # lire le fichier des groupes

# Enlever colonnes inutiles pour garder uniquement les espèces
tableau_especes = tableau.drop(columns=["Orthogroup", "Total"])


# Détermination de la présence/absence des orthogroups
presence = tableau_especes > 0  # True si présent, False sinon
nb_especes = presence.sum(axis=1)  # nombre d'espèces par OG
total_especes = tableau_especes.shape[1]  # nombre total d'espèces


# Classification des orthogroups
def classer(n):
    if n == total_especes:
        return "core"
    elif n == 1:
        return "specific"
    else:
        return "shared"


categories = nb_especes.apply(classer)  # catégorie pour chaque OG


# Création du tableau de résultats
resultat = pd.DataFrame(
    0,
    index=tableau_especes.columns,
    columns=["single", "multi", "shared", "specific"]
)


# Comptage des copies de gènes par espèce
for i in range(len(tableau_especes)):  # pour chaque orthogroup
    ligne = tableau_especes.iloc[i]  # valeurs de l'orthogroup
    categorie = categories.iloc[i]  # catégorie de cet OG

    # Séparation des gènes core en single-copy et multi-copy
    if categorie == "core":
        if (ligne == 1).all():
            categorie = "single"
        else:
            categorie = "multi"

    for espece in tableau_especes.columns:
        resultat.loc[espece, categorie] += ligne[espece]


# Calcul du total de gènes par espèce
resultat["total"] = resultat.sum(axis=1)

# Conversion en pourcentages
resultat_pct = resultat[["single", "multi", "shared", "specific"]].div(
    resultat["total"], axis=0
) * 100


# Attribution des groupes à partir du fichier TSV
def assigner_groupe(nom):
    for _, row in groupes.iterrows():
        if nom.startswith(row["Espece"]):
            return row["Groupe"]
    return "Inconnu"


resultat_pct["Groupe"] = [
    assigner_groupe(espece) for espece in resultat_pct.index
]


# Tri des espèces par groupe puis par nombre total de gènes
ordre_groupes = ["Chilopoda", "Diplopoda", "Outgroup"]
resultat_pct["Groupe"] = pd.Categorical(
    resultat_pct["Groupe"],
    categories=ordre_groupes,
    ordered=True
)

resultat_pct["Total"] = resultat["total"]

resultat_pct = resultat_pct.sort_values(
    by=["Groupe", "Total"],
    ascending=[True, False]
)


# Données pour le plot
single = resultat_pct["single"]
multi = resultat_pct["multi"]
shared = resultat_pct["shared"]
specific = resultat_pct["specific"]


# Création du graphique
plt.figure(figsize=(16, 8))

plt.bar(resultat_pct.index, single, label="single-copy", color="black", edgecolor="black")
plt.bar(resultat_pct.index, multi, bottom=single, label="multi-copy", color="orange", edgecolor="black")
plt.bar(resultat_pct.index, shared, bottom=single + multi, label="shared", color="lightblue", edgecolor="black")
plt.bar(resultat_pct.index, specific, bottom=single + multi + shared, label="specific", color="red", edgecolor="black")

plt.xticks(rotation=90, fontsize=8)
plt.ylabel("Pourcentage (%)")
plt.title("Distribution des gènes par espèce")


# Colorer les noms des espèces selon leur groupe
ax = plt.gca()
for label in ax.get_xticklabels():
    espece = label.get_text()
    groupe = resultat_pct.loc[espece, "Groupe"]

    if groupe == "Chilopoda":
        label.set_color("blue")
    elif groupe == "Diplopoda":
        label.set_color("darkorange")
    elif groupe == "Outgroup":
        label.set_color("green")


plt.legend()
plt.tight_layout()

plt.savefig("/home/amzallag/stage/Figures/stacked_plot_groupes.png", dpi=300)
plt.show()