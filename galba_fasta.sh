
mkdir doss_galba_fasta

fasta_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/extract_canonical_proteins/galba"

for i in $fasta_source/*/
do
  espece=$(basename "$i")                       # prendre slmt le nom du dossier (sans le chemin)
  mkdir "doss_galba_fasta/$espece"
  cp "$i"/*.fasta "doss_galba_fasta/$espece/"   # copier le fichier .fast de l’espèce dans son dossier dans doss_omark
done


