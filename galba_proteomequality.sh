
header="-H"  # option -H permet d'afficher le Header


for i in doss_galba_fasta/*  # On boucle sur les dossiers d'espèces dans doss_galba_fasta
do
  espece=$(basename "$i")    # prendre slmt le nom du dossier (sans le chemin)


  # Lancer ProteomeQuality en utilisant les chemins de tes 3  dossiers
  /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality \
  doss_galba_fasta/${espece}/*.fasta \
  -b doss_galba_busco/${espece} \
  -k doss_galba_omark/${espece} \
  -t $header >> galba_test.tsv


  header="" # Vide le header après le premier passage
done




