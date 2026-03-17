
mkdir doss_braker2_fasta

fasta_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/extract_canonical_proteins/braker2"

for i in $fasta_source/*/
do
  espece=$(basename "$i")                       # prendre slmt le nom du dossier (sans le chemin)
  mkdir "doss_braker2_fasta/$espece"
  cp "$i"/*.fasta "doss_braker2_fasta/$espece/"   # copier le fichier .fast de l’espèce dans son dossier dans doss_omark
done






mkdir doss_braker2_busco

busco_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/busco/braker2"

for i in $busco_source/*/
do
  espece=$(basename "$i")
  mkdir "doss_braker2_busco/$espece"
  cp "$i"/*.json "doss_braker2_busco/$espece/"
done






mkdir doss_braker2_omark

omark_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/omark/omark/braker2"

for i in "$omark_source"/*
do
    espece=$(basename "$i")
    mkdir "doss_braker2_omark/$espece"
    ln -s "$i/omark/"*.sum "doss_braker2_omark/$espece/"   # copier le fichier .sum de l’espèce dans son dossier dans doss_omark
done







# Proteomequality
header="-H"  # option -H permet d'afficher le Header


for i in doss_braker2_fasta/*  # On boucle sur les dossiers d'espèces dans doss_galba_fasta
do
  espece=$(basename "$i")    # prendre slmt le nom du dossier (sans le chemin)


  # Lancer le script en utilisant les chemins des 3  dossiers
  /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality \
  doss_braker2_fasta/${espece}/*.fasta \
  -b doss_braker2_busco/${espece} \
  -k doss_braker2_omark/${espece} \
  -t $header >> braker2_tableau.tsv


  header="" # Vide le header après le premier passage
done


mkdir -p complet_braker2
mv doss_braker2_fasta complet_braker2/
mv doss_braker2_busco complet_braker2/
mv doss_braker2_omark complet_braker2/
mv braker2_tableau.tsv complet_braker2/
