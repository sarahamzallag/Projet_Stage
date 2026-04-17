
GROUP_FILE="/home/amzallag/stage/script/groupe.tsv"
ORTHO_FILE="/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv"

TARGET_GROUP="$1"

# Étape 1 : Associer chaque espèce à son groupe
declare -A species_to_group
while IFS=$'\t' read -r espece groupe; do
    species_to_group["$espece"]="$groupe"
done < "$GROUP_FILE"

# Étape 2 : Lecture de l'en-tête
IFS=$'\t' read -r -a header < "$ORTHO_FILE"

# Étape 3 : Identifier les colonnes par groupe
declare -A group_cols

for i in "${!header[@]}"; do
    col_name="${header[$i]}"
    for sp in "${!species_to_group[@]}"; do
        if [[ "$col_name" == "$sp"* ]]; then
            grp="${species_to_group[$sp]}"
            group_cols["$grp"]+="$i "
            break
        fi
    done
done

# ... Etape 4 ...

count=0
total_proteins=0

{
    read -r  # Ignorer l'en-tête
    while IFS=$'\t' read -r -a line; do
        
        # --- CONDITION 1 : 100% Présent chez les Diplopodes ---
        present_in_diplos=1
        proteins_diplo=0
        for col in ${group_cols["Diplopoda"]}; do
            val=${line[$col]//[$'\r']/}; val=${val:-0}
            if (( val == 0 )); then present_in_diplos=0; break; fi
            ((proteins_diplo += val))
        done

        [[ $present_in_diplos -eq 0 ]] && continue

        # --- CONDITION 2 : Au moins une absence dans CHAQUE autre groupe ---
        all_others_have_gap=1
        
        for grp in "${!group_cols[@]}"; do
            [[ "$grp" == "Diplopoda" ]] && continue  # On ne s'occupe pas du groupe cible
            
            has_zero_in_this_group=0
            for col in ${group_cols[$grp]}; do
                val=${line[$col]//[$'\r']/}; val=${val:-0}
                if (( val == 0 )); then
                    has_zero_in_this_group=1
                    break
                fi
            done
            
            # Si le groupe actuel est 100% complet (pas de zéro), alors la condition échoue
            if (( has_zero_in_this_group == 0 )); then
                all_others_have_gap=0
                break
            fi
        done

        # --- COMPTAGE FINAL ---
        if (( all_others_have_gap == 1 )); then
            ((count++))
            ((total_proteins += proteins_diplo))
            # Optionnel : echo "${line[0]}" # Pour voir les noms des Orthogroupes
        fi

    done
} < "$ORTHO_FILE"

echo "Nombre d'orthogroupes spécifiques (100% Diplo + absences ailleurs) : $count"
echo "Nombre total de protéines associées : $total_proteins"