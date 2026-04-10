#!/usr/bin/env bash
#SBATCH --job-name=orthofinder
#SBATCH --output=/home/amzallag/stage/log/orthofinder_%j.out
#SBATCH --error=/home/amzallag/stage/log/orthofinder_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.amzallag@etu.unistra.fr
#SBATCH --partition=lab
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40

module load ortho/orthofinder/2.5.5
cd /home/amzallag/stage
orthofinder -f agat/fasta_orthofinder -t 40


# A TAPER DS TERMINAL
#sbatch script_orthofinder.sh
#squeue