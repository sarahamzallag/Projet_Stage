
mkdir doss_brakerS_fasta

fasta_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/extract_canonical_proteins/braker_with_star"

for i in $fasta_source/*/
do
  espece=$(basename "$i")                       # prendre slmt le nom du dossier (sans le chemin)
  mkdir "doss_brakerS_fasta/$espece"
  cp "$i"/*.fasta "doss_brakerS_fasta/$espece/"   # copier le fichier .fast de l’espèce dans son dossier dans doss_omark
done





mkdir doss_brakerS_busco

busco_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/busco/braker_with_star"

for i in $busco_source/*/
do
  espece=$(basename "$i")
  mkdir "doss_brakerS_busco/$espece"
  cp "$i"/*.json "doss_brakerS_busco/$espece/"
done






mkdir doss_brakerS_omark

omark_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/omark/omark/braker_with_star"

for i in "$omark_source"/*
do
    espece=$(basename "$i")
    mkdir "doss_brakerS_omark/$espece"
    ln -s "$i/omark/"*.sum "doss_brakerS_omark/$espece/"   # copier le fichier .sum de l’espèce dans son dossier dans doss_omark
done







# Proteomequality
header="-H"  # option -H permet d'afficher le Header


for i in doss_brakerS_fasta/*  # On boucle sur les dossiers d'espèces dans doss_galba_fasta
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


mkdir complet_brakerS
mv doss_brakerS_fasta complet_brakerS/
mv doss_brakerS_busco complet_brakerS/
mv doss_brakerS_omark complet_brakerS/
mv brakerS_tableau.tsv complet_brakerS/


