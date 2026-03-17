
mkdir doss_brakerS_fasta

fasta_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/extract_canonical_proteins/braker_with_star/"

for i in $fasta_source/*/
do
  espece=$(basename "$i")                       
  mkdir "doss_brakerS_fasta/$espece"
  cp "$i"/*.fasta "doss_brakerS_fasta/$espece/"
done






mkdir doss_brakerS_busco

busco_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/busco/all_busco_results"

for i in $busco_source/*star.json
do
  espece=$(basename "$i" | sed 's/.*busco_//' | sed 's/_braker.*//') # Extrait le nom de l'espece (coupe avant busco_ et après _braker)
  mkdir "doss_brakerS_busco/$espece"
  cp "$i" "doss_brakerS_busco/$espece/"
done 







mkdir doss_brakerS_omark

omark_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/omark/omark/braker_with_star/"

for i in "$omark_source"/*
do
    espece=$(basename "$i")
    mkdir "doss_brakerS_omark/$espece"
    cp "$i/omark/"*.sum "doss_brakerS_omark/$espece/"   # copier le fichier .sum de l’espèce dans son dossier dans doss_omark
done






# Proteomequality

header="-H"  # option -H permet d'afficher le Header

for i in doss_brakerS_fasta/*  # On boucle sur les dossiers d'espèces dans doss_fasta
do
  espece=$(basename "$i")    # prendre slmt le nom du dossier (sans le chemin)


  # Lancer le script en utilisant les chemins des 3  dossiers
  /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality \
  doss_brakerS_fasta/${espece}/*.fasta \
  -b doss_brakerS_busco/${espece} \
  -k doss_brakerS_omark/${espece} \
  -t $header >> brakerS_tableau.tsv


  header="" # Vide le header après le premier passage
done





mkdir -p complet_brakerS
mv doss_brakerS_fasta complet_brakerS/
mv doss_brakerS_busco complet_brakerS/
mv doss_brakerS_omark complet_brakerS/
mv brakerS_tableau.tsv complet_brakerS/