
import matplotlib.pyplot as plt

# Mets tes valeurs ici
categories = ["Core espèces", "Commun chilo", "Commun diplo", "Spécifique chilo", "Spécifique diplo"]
valeurs = [2268, 3590, 4205, 99, 43]

# Création du graphique
plt.figure()
plt.bar(categories, valeurs)

# Labels
plt.ylabel("Nombre d'orthogroups")
plt.title("Comparaison des orthogroups")

# Affichage
plt.savefig("/home/amzallag/stage/Figures/plot.png")
plt.show()
