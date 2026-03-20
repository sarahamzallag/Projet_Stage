for nom_source in "$@"   # argument donné en ligne de commande - peu importe combien il y en a (sinon $1)
do

chemin="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version"   # chemin commun

fasta_source="$chemin/extract_canonical_proteins/$nom_source"
busco_source="$chemin/busco/$nom_source"
omark_source="$chemin/omark/omark/$nom_source"

nom_dossier="$nom_source"  # nom des dossiers de sortie

sortie="/home/amzallag/stage/complet" # dossier où écrire les résultats

mkdir -p "$sortie/complet_${nom_dossier}"   # créer le dossier final



#FASTA 
mkdir -p "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_fasta"

for i in $fasta_source/*/              # boucle sur les dossiers d'espèces
do
  espece=$(basename "$i")              # récupérer le nom de l'espèce
  mkdir -p "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_fasta/$espece"   # créer le dossier pour chaque espèce
  cp "$i"/*.fasta "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_fasta/$espece/"   # copier les .fasta dedans
done



#BUSCO
mkdir -p "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_busco"
for i in $busco_source/*/
do
  espece=$(basename "$i")              # récupérer le nom de l'espèce
  mkdir -p "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_busco/$espece"   # créer dossier espèce
  cp "$i"/*.json "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_busco/$espece/"   # copier les .json
done



# OMARK
mkdir -p "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_omark"   # créer le dossier omark

for i in "$omark_source"/*
do
  espece=$(basename "$i")               # récupérer le nom de l'espèce
  mkdir -p "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_omark/$espece"   # créer dossier espèce
  ln -s "$i/omark/"*.sum "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_omark/$espece/"   # créer lien vers les .sum
done



# PROTEOME_QUALITY
header="-H"    # option -H permet d'afficher le Header

for i in "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_fasta/"*
do
  espece=$(basename "$i")   # nom de l'espèce

  /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality \
  "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_fasta/${espece}"/*.fasta \
  -b "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_busco/${espece}" \
  -k "$sortie/complet_${nom_dossier}/doss_${nom_dossier}_omark/${espece}" \
  -t $header >> "$sortie/complet_${nom_dossier}/${nom_dossier}_tableau.tsv"

  header=""   # enlever header après le premier passage
done

done

# bash complet.sh galba braker2 braker_with_star braker_with_varus