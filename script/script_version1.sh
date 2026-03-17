

mkdir doss_fasta
for i in doss_busco/*                    # prendre les doss 
do
    espece=$(basename "$i")              # prendre slmt le nom du dossier (sans le chemin)
    cp /gstock/metainvert/results/myriapods_annotation/proteomes_analysis/canonical_proteins/${espece}/${espece}_proteins.fasta doss_fasta
done






mkdir doss_busco
busco_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/busco/busco_results"
for i in $busco_source/*.json   # Dans le dossier busco_source, prendre  tous les fichiers .json
do                                   
    espece=$(basename "$i")  # slmt les fichier.json sans le chemin absolut
    nom=$(echo $espece| cut -d "_" -f4)
    mkdir "doss_busco/$nom"
    cp "$i" "doss_busco/$nom/"
done




mkdir doss_omark
omark_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/omark/omark_results"
for i in $omark_source/*/              # prendre slmt les dossiers, pas les fichiers
do
  espece=$(basename "$i")              # prendre slmt le nom du dossier (sans le chemin)
  mkdir "doss_omark/$espece"
  cp "$i/omark/"*.sum "doss_omark/$espece/" # copier le fichier .sum de l’espèce dans son dossier dans doss_omark
done





header="-H"                      # option -H permet d'afficher le Header
for i in doss_busco/*            # prendre les doss 
do
  espece=$(basename "$i")              # prendre slmt le nom du dossier (sans le chemin)
  
  ## lancer ProteomeQuality pour l'espèce (proteome, busco,omark) et ajouter le résultat dans afact.txt
  /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality /gstock/metainvert/results/myriapods_annotation/proteomes_analysis/canonical_proteins/${espece}/${espece}_proteins.fasta -b doss_busco/${espece} -k doss_omark/${espece} -t $header >> afact.tsv
  
  
  header="" # pour quil ne s'affiche que pour la 1ere espece  
done

