
mkdir doss_busco
busco_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/busco/busco_results"
for i in $busco_source/*.json   # Dans le dossier busco_source, prendre  tous les fichiers .json
do                                   
    espece=$(basename "$i")  # slmt les fichier.json sans le chemin absolut
    nom=$(echo $espece| cut -d "_" -f4)
    mkdir "doss_busco/$nom"
    cp "$i" "doss_busco/$nom/"
done




