
# cherche dans le dossier courant (.) et tous ses sous-dossiers, un fichier dont le nom correspond exactement à i et le copie ds fasta_orthofinder

for i in \
"pachymerium-ferrugineum_galba_proteins.fasta"\
"strigamia-acuminata-1_braker_with_star_proteins.fasta"\
"strigamia-maritima_braker_with_star_proteins.fasta"\
"lithobius-variegatus-1_braker_with_star_proteins.fasta"\
"rhysida-immarginata_braker_with_star_proteins.fasta"\
"scolopendra-cretica_braker_with_star_proteins.fasta" \
"nanogona-polydesmoides-1_braker_with_star_proteins.fasta" \
"choneiulus-palmatus-1_galba_proteins.fasta" \
"cylindroiulus-punctatus-1_braker_with_star_proteins.fasta" \
"julidae-sp-jj-2019_braker_with_star_proteins.fasta" \
"brachycybe-producta-1_braker_with_star_proteins.fasta" \
"polydesmus-complanatus_galba_proteins.fasta" \
"agaricogonopus-acrotrifoliolatus_braker_with_star_proteins.fasta" \
"trigoniulus-corallinus_braker_with_star_proteins.fasta"
do
  find . -name "$i" -exec cp -n {} ~/stage/agat/fasta_orthofinder/ \;
done

# Etre ds le doss 'complet'