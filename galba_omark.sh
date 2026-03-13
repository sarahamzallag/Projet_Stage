
mkdir doss_galba_omark

omark_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/omark/omark/galba"

for i in "$omark_source"/*
do
    espece=$(basename "$i")
    mkdir "doss_galba_omark/$espece"
    cp "$i/omark/"*.sum "doss_galba_omark/$espece/"   # copier le fichier .fast de l’espèce dans son dossier dans doss_omark
done



