
header="-H"                      # option -H permet d'afficher le Header
for i in doss_busco/*            # prendre les doss 
do
  espece=$(basename "$i")              # prendre slmt le nom du dossier (sans le chemin)
  
  ## lancer ProteomeQuality pour l'espèce (proteome, busco,omark) et ajouter le résultat dans afact.txt
  /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality /gstock/metainvert/results/myriapods_annotation/proteomes_analysis/canonical_proteins/${espece}/${espece}_proteins.fasta -b doss_busco/${espece} -k doss_omark/${espece} -t $header >> afact.tsv
  
  
  header="" # pour quil ne s'affiche que pour la 1ere espece  
done
