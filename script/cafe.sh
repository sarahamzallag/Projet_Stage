
module load phylo/cafe
# chemins
source_gene="/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv"
source_tree="/home/amzallag/stage/OrthoFinder/Results_Mar26/Species_Tree/SpeciesTree_rooted.txt"
cafe="/home/amzallag/stage/cafe"

# créer dossier
mkdir -p $cafe

# copier fichiers
cp $source_gene $cafe/
cp $source_tree $cafe/


# aller dans dossier
cd $cafe

# enlever colonne Total (IMPORTANT)
cut -f1-$(($(head -n1 Orthogroups.GeneCount.tsv | tr '\t' '\n' | wc -l)-1)) Orthogroups.GeneCount.tsv > tmp.txt
mv tmp.txt Orthogroups.GeneCount.tsv


# créer fichier cafe.txt automatiquement
cat <<EOF > cafe.txt
load -i Orthogroups.GeneCount.tsv -t 4 -l log.txt
tree $(cat SpeciesTree_rooted.txt)
lambda -s
report cafe_results
EOF

# lancer cafe
cafe cafe.txt

