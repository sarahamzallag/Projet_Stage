
mkdir doss_omark
omark_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/omark/omark_results"
for i in $omark_source/*/              # prendre slmt les dossiers, pas les fichiers
do
  espece=$(basename "$i")              # prendre slmt le nom du dossier (sans le chemin)
  mkdir "doss_omark/$espece"
  cp "$i/omark/"*.sum "doss_omark/$espece/" # copier le fichier .sum de l’espèce dans son dossier dans doss_omark
done