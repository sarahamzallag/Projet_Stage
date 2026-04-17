#!/bin/bash

# 1. Chemins des fichiers
FICHIER_MAPPING="/home/amzallag/stage/script/groupe.tsv"
FICHIER_ORTHOFINDER="/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv"
DOSSIER_SORTIE="/home/amzallag/stage/venn2"

# Création du dossier de sortie
mkdir -p "$DOSSIER_SORTIE"

# 2. Traitement avec AWK
awk -v FS="\t" -v OFS="\t" '
NR == FNR {
    if (NR > 1) { mapping[$1] = $2 }
    next
}
FNR == 1 {
    for (i = 2; i < NF; i++) {
        for (espece in mapping) {
            if ($i ~ espece) {
                if (mapping[espece] == "Diplopoda") diplo_cols[i]
                else if (mapping[espece] == "Chilopoda") chilo_cols[i]
                else autres_cols[i]
            }
        }
    }
    next
}
{
    D = 0; C = 0; A = 0; count_species = 0
    # Compte le nombre d espèces au total pour cet orthogroupe
    for (i = 2; i < NF; i++) { if ($i > 0) count_species++ }

    # CONDITION : Uniquement si partagé par AU MOINS 2 espèces
    if (count_species >= 2) {
        for (i in diplo_cols) if ($i > 0) D = 1
        for (i in chilo_cols) if ($i > 0) C = 1
        for (i in autres_cols) if ($i > 0) A = 1

        # Export des listes spécifiques (mais partagées par >= 2 espèces)
        if (D > 0 && C == 0 && A == 0) { print $1 > "'$DOSSIER_SORTIE'/diplo_shared_min2.txt"; d_spec++ }
        if (C > 0 && D == 0 && A == 0) { print $1 > "'$DOSSIER_SORTIE'/chilo_shared_min2.txt"; c_spec++ }
        if (A > 0 && D == 0 && C == 0) { print $1 > "'$DOSSIER_SORTIE'/others_shared_min2.txt"; a_spec++ }

        # Comptage pour les intersections
        if (D > 0 && C > 0 && A > 0) centre++
        if (D > 0 && C > 0 && A == 0) dc_only++
        if (D > 0 && A > 0 && C == 0) da_only++
        if (C > 0 && A > 0 && D == 0) ca_only++
    }
}
END {
    print "\n--- VENN DIAGRAM RESULTS (Shared by >= 2 species) ---"
    print "Specific Diplopoda (min 2 sp):  " (d_spec ? d_spec : 0)
    print "Specific Chilopoda (min 2 sp):  " (c_spec ? c_spec : 0)
    print "Specific Others (min 2 sp):     " (a_spec ? a_spec : 0)
    print "Intersection D-C-A:             " (centre ? centre : 0)
    print "Intersection D-C only:          " (dc_only ? dc_only : 0)
    print "Intersection D-A only:          " (da_only ? da_only : 0)
    print "Intersection C-A only:          " (ca_only ? ca_only : 0)
    print "--------------------------------------------------------------"
    print "Files generated in: '$DOSSIER_SORTIE'"
} ' "$FICHIER_MAPPING" "$FICHIER_ORTHOFINDER"