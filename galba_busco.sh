
mkdir doss_galba_busco

busco_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/busco/all_busco_results"

for i in $busco_source/*galba.json
do
  espece=$(basename "$i" | sed 's/.*busco_//' | sed 's/_galba.*//') # Extrait le nom de l'espece (coupe avant busco_ et après _galba)
  mkdir "doss_galba_busco/$espece"
  cp "$i" "doss_galba_busco/$espece/"
done