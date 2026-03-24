
for nom_source in "$@"   # argument donné en ligne de commande - peu importe combien il y en a (sinon $1)
do

chemin="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version"   # chemin commun

fasta_source="$chemin/filter_omark_contaminations/${nom_source}_filtered_c_0.33"
busco_source="$chemin/busco_on_contamination_filtered/${nom_source}_filtered_c_0.33"
omark_source="$chemin/omark_on_contamination_filtered/${nom_source}_filtered_c_0.33"

nom_dossier="$nom_source"  # nom des dossiers de sortie

sortie="/home/amzallag/stage/filtered" # dossier où écrire les résultats

mkdir -p "$sortie/filtered_${nom_dossier}"   # créer le dossier final



#FASTA 
mkdir -p "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_fasta"

for i in $fasta_source/*/              # boucle sur les dossiers d'espèces
do
  espece=$(basename "$i")              # récupérer le nom de l'espèce
  mkdir -p "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_fasta/$espece"   # créer le dossier pour chaque espèce
  cp "$i"/*.fa "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_fasta/$espece/"   # copier les .fasta dedans
done



#BUSCO
mkdir -p "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_busco"
for i in $busco_source/*/
do
  espece=$(basename "$i")              # récupérer le nom de l'espèce
  mkdir -p "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_busco/$espece"   # créer dossier espèce
  cp "$i"/*.json "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_busco/$espece/"   # copier les .json
done




# OMARK
mkdir -p "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_omark"   # créer le dossier omark

for i in "$omark_source"/*
do
  espece=$(basename "$i")               # récupérer le nom de l'espèce
  mkdir -p "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_omark/$espece"   # créer dossier espèce
  ln -s "$i/"*.sum "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_omark/$espece/"   # créer lien vers les .sum
done


# PROTEOME_QUALITY
header="-H"    # option -H permet d'afficher le Header

for i in "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_fasta/"*
do
  espece=$(basename "$i")   # nom de l'espèce

  /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality \
  "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_fasta/${espece}"/*.fa \
  -b "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_busco/${espece}" \
  -k "$sortie/filtered_${nom_dossier}/doss_${nom_dossier}_omark/${espece}" \
  -t $header >> "$sortie/filtered_${nom_dossier}/${nom_dossier}_tableau.tsv"

  header=""   # enlever header après le premier passage
done



done



# awk 'FNR==1 && NR!=1 {next} {print}' /home/amzallag/stage/complet/complet_*/*_tableau.tsv /home/amzallag/stage/filtered/filtered_*/*_tableau.tsv > /home/amzallag/stage/tableauexcel.tsv
# (head -n 1 /home/amzallag/stage/tableauexcel.tsv && tail -n +2 /home/amzallag/stage/tableauexcel.tsv | sort) > tmp && mv tmp /home/amzallag/stage/tableauexcel.tsv




