
mkdir doss_brakerV_fasta

fasta_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/extract_canonical_proteins/braker_with_varus"

for i in $fasta_source/*/
do
  espece=$(basename "$i")                       # prendre slmt le nom du dossier (sans le chemin)
  mkdir "doss_brakerV_fasta/$espece"
  cp "$i"/*.fasta "doss_brakerV_fasta/$espece/"   # copier le fichier .fast de l’espèce dans son dossier dans doss_omark
done





mkdir doss_brakerV_busco

busco_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/busco/braker_with_varus"

for i in $busco_source/*/
do
  espece=$(basename "$i")
  mkdir "doss_brakerV_busco/$espece"
  cp "$i"/*.json "doss_brakerV_busco/$espece/"
done






mkdir doss_brakerV_omark

omark_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/omark/omark/braker_with_varus"

for i in "$omark_source"/*
do
    espece=$(basename "$i")
    mkdir "doss_brakerV_omark/$espece"
    ln -s "$i/omark/"*.sum "doss_brakerV_omark/$espece/"   # copier le fichier .sum de l’espèce dans son dossier dans doss_omark
done







# Proteomequality
header="-H"  # option -H permet d'afficher le Header


for i in doss_brakerV_fasta/*  # On boucle sur les dossiers d'espèces dans doss_galba_fasta
do
  espece=$(basename "$i")    # prendre slmt le nom du dossier (sans le chemin)


  # Lancer le script en utilisant les chemins des 3  dossiers
  /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality \
  doss_brakerV_fasta/${espece}/*.fasta \
  -b doss_brakerV_busco/${espece} \
  -k doss_brakerV_omark/${espece} \
  -t $header >> brakerV_tableau.tsv


  header="" # Vide le header après le premier passage
done


mkdir complet_brakerV
mv doss_brakerV_fasta complet_brakerV/
mv doss_brakerV_busco complet_brakerV/
mv doss_brakerV_omark complet_brakerV/
mv brakerV_tableau.tsv complet_brakerV/


