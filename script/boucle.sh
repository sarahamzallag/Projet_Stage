
# nom_dossier=$1

# chemin_entier="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/omark/omark/${nom_dossier}"

# echo $chemin_entier
# ls $chemin_entier

list_dossier="braker2
braker_with_star
braker_with_varus
galba"

for i in $list_dossier; do
    chemin_entier="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/omark/omark/${i}"
    echo $chemin_entier
    especes=$(ls $chemin_entier)

    for espece in $especes; do 
        echo $espece

        fasta="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/extract_canonical_proteins/$i/$espece/*fasta"
        echo $fasta
    done

    echo ''

    # mkdir -p doss_${i}_fasta

    # fasta_source="/gstock/metainvert/results/myriapods_annotation/proteomes_analysis/second_version/extract_canonical_proteins/${i}"

    # for i in $fasta_source/*/
    # do
    # espece=$(basename "$i")                       # prendre slmt le nom du dossier (sans le chemin)
    # mkdir -p "doss_${i}_fasta/$espece"
    # cp "$i"/*.fasta "doss_${i}_fasta/$espece/"   # copier le fichier .fast de l’espèce dans son dossier dans doss_omark
    # done
done


















