# 1. Chemins des fichiers
FICHIER_MAPPING="/home/amzallag/stage/script/groupe.tsv"
FICHIER_ORTHOFINDER="/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv"
DOSSIER_SORTIE="/home/amzallag/stage/venn"

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
    D = 0; C = 0; A = 0
    for (i in diplo_cols) D += $i
    for (i in chilo_cols) C += $i
    for (i in autres_cols) A += $i

    if (D > 0 && C == 0 && A == 0) { print $1 > "'$DOSSIER_SORTIE'/diplo_orthogroup_specifique.txt"; d_spec++ }
    if (C > 0 && D == 0 && A == 0) { print $1 > "'$DOSSIER_SORTIE'/chilo_orthogroup_specifique.txt"; c_spec++ }
    if (A > 0 && D == 0 && C == 0) { print $1 > "'$DOSSIER_SORTIE'/autres_orthogroup_specifique.txt"; a_spec++ }

    if (D > 0 && C > 0 && A > 0) centre++
    if (D > 0 && C > 0 && A == 0) dc_only++
    if (D > 0 && A > 0 && C == 0) da_only++
    if (C > 0 && A > 0 && D == 0) ca_only++
}
END {
    print "\n--- VENN DIAGRAM RESULTS ---"
    print "Specific Diplopoda:      " d_spec
    print "Specific Chilopoda:      " c_spec
    print "Specific Others:         " a_spec
    print "Intersection D-C-A:      " centre
    print "Intersection D-C only:   " dc_only
    print "Intersection D-A only:   " da_only
    print "Intersection C-A only:   " ca_only
    print "-------------------------------------------"
    print "Files generated in '$DOSSIER_SORTIE'"
} ' "$FICHIER_MAPPING" "$FICHIER_ORTHOFINDER"