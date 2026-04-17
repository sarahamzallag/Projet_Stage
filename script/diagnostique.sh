
# 1. On récupère les colonnes du fichier GeneCount (une par ligne)
head -n 1 /home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv | tr '\t' '\n' | grep -vE "Orthogroup|Total" > colonnes_reelles.txt

# 2. On récupère les noms d espèces de ton mapping
tail -n +2 /home/amzallag/stage/script/groupe.tsv | cut -f1 > noms_mapping.txt

# 3. On regarde qui est dans le fichier mais PAS dans ton mapping
echo "--- ESPÈCES PRÉSENTES DANS LE FICHIER MAIS NON RECONNUES ---"
grep -vFf noms_mapping.txt colonnes_reelles.txt

