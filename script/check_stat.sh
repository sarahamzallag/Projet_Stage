#!/bin/bash

RESULT_CASCADE="/home/amzallag/stage/result_cascade.tsv"
STAT_OFFICIEL="/home/amzallag/stage/OrthoFinder/Results_Mar26/Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv"

awk -F'\t' '
# 1. On lit les stats officielles
FILENAME == "'"$STAT_OFFICIEL"'" {
    if (FNR == 1) {
        for(i=2; i<=NF; i++) { 
            name = $i; gsub(/_/, "-", name); col_sp[i] = name 
        }
    }
    if ($1 == "Number of genes") {
        for(i=2; i<=NF; i++) { match_stats[col_sp[i]] = $i }
    }
}

# 2. On compare avec ton résultat
FILENAME == "'"$RESULT_CASCADE"'" {
    if (FNR > 1 && $1 != "Espece" && $1 != "Species") {
        # Addition de toutes les colonnes PROT
        total_graph = $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9
        sp_clean = $1; gsub(/_/, "-", sp_clean);
        
        found = 0
        for (s in match_stats) {
            # On vérifie si un nom est contenu dans l autre
            if (index(sp_clean, s) > 0 || index(s, sp_clean) > 0) {
                if (total_graph == match_stats[s]) {
                    printf "%-35s : OK  (%d)\n", $1, total_graph
                } else {
                    printf "%-35s : ERREUR  (Graph:%d vs Stat:%d)\n", $1, total_graph, match_stats[s]
                }
                found = 1; break
            }
        }
        if (!found) printf "%-35s : Inconnu dans les stats \n", $1
    }
}
' "$STAT_OFFICIEL" "$RESULT_CASCADE"