#!/usr/bin/env bash
#SBATCH --job-name=agat
#SBATCH --output=/home/amzallag/stage/log/agat_%j.out
#SBATCH --error=/home/amzallag/stage/log/agat_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.amzallag@etu.unistra.fr
#SBATCH --partition=lab
#SBATCH --nodes=1
#SBATCH --ntasks=1


while read espece accession                           #lire le fichier 'fiche_espece' ligne par ligne (colonne1=espece et colonne2=num GCF )
do
    
   mkdir -p "/home/amzallag/stage/agat/$espece"       #créer un dossier avec le nom de lespece ds doss agat
   cd "/home/amzallag/stage/agat/$espece" || exit     # rentre ds le doss si n'existe pas Fin du script

   num=${accession#GCF_}                              # enlever GCF_ puis la version .1
   num=${num%%.*}

   a=${num:0:3}                                       # couper en blocs de 3 pour faire le chemin NCBI
   b=${num:3:3}
   c=${num:6:3}
   path="$a/$b/$c"

   base="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/$path"  # URL perso de l'espece

   dossier=$(wget -qO- "$base/" | grep -o "${accession}[^\"/]*" | head -n 1)  # Trouve le nom complet du dossier

   wget "$base/$dossier/${dossier}_genomic.gff.gz"  # télécharger les fichiers gff et fna
   wget "$base/$dossier/${dossier}_genomic.fna.gz"  
   gunzip -f *.gz     # Dezipe les fichier

   agat_sp_keep_longest_isoform.pl --gff *_genomic.gff -o longest.gff  # garder le + long isoforme par gène (sortie : longest.gff)
   agat_sp_extract_sequences.pl -g longest.gff -f *_genomic.fna -p -o "${espece}.fa"  # extraire les prot à partir de longest.gff et du génome (sortie .fa )

   mkdir -p /home/amzallag/stage/agat/fasta_orthofinder      # Mettre tt les .fa  ds fasta.orthofinder 
   cp /home/amzallag/stage/agat/*/*.fa /home/amzallag/stage/agat/fasta_orthofinder/

done < /home/amzallag/stage/fiche_espece


# A TAPER DS TERMINAL
#sbatch agat.sh
#squeue
#pour annuler "scancel 7886"
#
# Si on enleve  SLURM ne pas oublier de taper ds terminal "conda activate agat_env"
