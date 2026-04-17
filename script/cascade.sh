#!/bin/bash

# --- CONFIGURATION DES CHEMINS ---
SEUILS="/home/amzallag/stage/seuil.tsv"
MAPPING="/home/amzallag/stage/script/groupe.tsv"
ORTHO="/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv"
SINGLETONS="/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups_UnassignedGenes.tsv"
SORTIE="/home/amzallag/stage/result_cascade.tsv"

awk -F'\t' '
FILENAME == "'"$SEUILS"'" { if (FNR > 1) { s100[$1]=$2; s75[$1]=$3 } next }
FILENAME == "'"$MAPPING"'" { gsub(/\r/, "", $1); gsub(/\r/, "", $2); map[$1]=$2; liste_sp[++nb_sp]=$1; next }

FILENAME == "'"$SINGLETONS"'" {
    if (FNR == 1) {
        for(i=2; i<=NF; i++) { for(sp in map) { if (index($i, sp) > 0) { col_to_sp_s[i] = sp } } }
    } else {
        for(i=2; i<=NF; i++) { if(length($i) > 1 && col_to_sp_s[i] != "") { singletons_par_sp[col_to_sp_s[i]] += 1 } }
    }
    next
}

FILENAME == "'"$ORTHO"'" {
    if (FNR == 1) {
        for(i=2; i<=NF; i++) { for(sp in map) { if (index($i, sp) > 0) { col_grp[i] = map[sp]; sp_de_col[i] = sp } } }
        next
    }
    n_art=0; n_myr=0; n_dip=0; n_chi=0; n_cru=0; n_che=0; n_hex=0
    for(i=2; i<NF; i++) {
        if($i > 0) {
            g = col_grp[i]; if(g != "" && g != "Tardigrada") n_art++
            if(g == "Diplopoda" || g == "Chilopoda") n_myr++
            if(g == "Diplopoda") n_dip++
            if(g == "Chilopoda") n_chi++
            if(g == "Crustacea") n_cru++
            if(g == "Chelicerata") n_che++
            if(g == "Hexapoda") n_hex++
        }
    }
    for(i=2; i<NF; i++) {
        if($i > 0 && sp_de_col[i] != "") {
            s = sp_de_col[i]; g = col_grp[i]; p = $i
            if (n_art == s100["Arthropoda"])      res = "100a"
            else if (n_art >= s75["Arthropoda"])  res = "75a"
            else if ((g == "Diplopoda" || g == "Chilopoda") && n_myr == s100["Myriapoda"]) res = "100m"
            else if ((g == "Diplopoda" || g == "Chilopoda") && n_myr >= s75["Myriapoda"])  res = "75m"
            else if ((g == "Diplopoda" && n_dip == s100["Diplopoda"]) || (g == "Chilopoda" && n_chi == s100["Chilopoda"]) || (g == "Crustacea" && n_cru == s100["Crustacea"]) || (g == "Chelicerata" && n_che == s100["Chelicerata"]) || (g == "Hexapoda" && n_hex == s100["Hexapoda"])) res = "100g"
            else if ((g == "Diplopoda" && n_dip >= s75["Diplopoda"]) || (g == "Chilopoda" && n_chi >= s75["Chilopoda"]) || (g == "Crustacea" && n_cru >= s75["Crustacea"]) || (g == "Chelicerata" && n_che >= s75["Chelicerata"]) || (g == "Hexapoda" && n_hex >= s75["Hexapoda"])) res = "75g"
            else if (n_art == 1) res = "spec"
            else res = "autre"
            prot_count[s, res] += p
        }
    }
}

END {
    for(s in singletons_par_sp) { prot_count[s, "spec"] += singletons_par_sp[s] }
    tags[1]="100a"; tags[2]="75a"; tags[3]="100m"; tags[4]="75m"; tags[5]="100g"; tags[6]="75g"; tags[7]="spec"; tags[8]="autre"
    printf "Species"
    for(t=1; t<=8; t++) printf "\tPROT_%s", tags[t]
    printf "\n"
    for(j=1; j<=nb_sp; j++) {
        s = liste_sp[j]; printf "%s", s
        for(t=1; t<=8; t++) printf "\t%d", prot_count[s,tags[t]]
        printf "\n"
    }
}' "$SEUILS" "$MAPPING" "$SINGLETONS" "$ORTHO" > "$SORTIE"