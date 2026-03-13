mkdir doss_brakerS_omark

omark_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/omark/omark/braker_with_star/"

for i in "$omark_source"/*
do
    espece=$(basename "$i")
    mkdir "doss_brakerS_omark/$espece"
    cp "$i/omark/"*.sum "doss_brakerS_omark/$espece/"   # copier le fichier .sum de l’espèce dans son dossier dans doss_omark
done