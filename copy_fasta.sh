
mkdir doss_fasta
for i in doss_busco/*                    # prendre les doss 
do
    espece=$(basename "$i")              # prendre slmt le nom du dossier (sans le chemin)
    cp /gstock/metainvert/results/myriapods_annotation/proteomes_analysis/canonical_proteins/${espece}/${espece}_proteins.fasta doss_fasta
done