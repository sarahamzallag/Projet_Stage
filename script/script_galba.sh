
mkdir doss_galba_fasta

fasta_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/extract_canonical_proteins/galba"

for i in $fasta_source/*/
do
  espece=$(basename "$i")                       # prendre slmt le nom du dossier (sans le chemin)
  mkdir "doss_galba_fasta/$espece"
  cp "$i"/*.fasta "doss_galba_fasta/$espece/"   # copier le fichier .fast de l’espèce dans son dossier dans doss_omark
done





mkdir doss_galba_busco

busco_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/busco/galba"

for i in $busco_source/*/
do
  espece=$(basename "$i")
  mkdir "doss_galba_busco/$espece"
  cp "$i"/*.json "doss_galba_busco/$espece/"
done






mkdir doss_galba_omark

omark_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/omark/omark/galba"

for i in "$omark_source"/*
do
    espece=$(basename "$i")
    mkdir "doss_galba_omark/$espece"
    ln -s "$i/omark/"*.sum "doss_galba_omark/$espece/"   # copier le fichier .sum de l’espèce dans son dossier dans doss_omark
done







# Proteomequality
header="-H"  # option -H permet d'afficher le Header


for i in doss_galba_fasta/*  # On boucle sur les dossiers d'espèces dans doss_galba_fasta
do
  espece=$(basename "$i")    # prendre slmt le nom du dossier (sans le chemin)


  # Lancer le script en utilisant les chemins des 3  dossiers
  /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality \
  doss_galba_fasta/${espece}/*.fasta \
  -b doss_galba_busco/${espece} \
  -k doss_galba_omark/${espece} \
  -t $header >> galba_tableau.tsv


  header="" # Vide le header après le premier passage
done


mkdir complet_galba
mv doss_galba_fasta complet_galba/
mv doss_galba_busco complet_galba/
mv doss_galba_omark complet_galba/
mv galba_tableau.tsv complet_galba/


