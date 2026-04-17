# Definition des chemins
FICHIER_MAPPING="/home/amzallag/stage/script/groupe.tsv"
FICHIER_ORTHOFINDER="/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv"
FICHIER_SORTIE="/home/amzallag/stage/count_orthogroupe.tsv"

awk -F'\t' '
# 1. Lecture du mapping (Espece -> Groupe)
NR==FNR {
    tableau_espece_vers_groupe[$1] = $2
    next
}

# 2. Preparation de la correspondance des colonnes
FNR==1 {
    for(i=2; i<NF; i++) {
        for(nom_espece in tableau_espece_vers_groupe) {
            if(index($i, nom_espece)) {
                correspondance_colonne_groupe[i] = tableau_espece_vers_groupe[nom_espece]
            }
        }
    }
    # En-tete complet avec Myriapoda et Arthropoda
    print "Orthogroup\tChelicerata\tHexapoda\tCrustacea\tDiplopoda\tChilopoda\tMyriapoda\tArthropoda"
    next
}

# 3. Comptage par groupe et calcul des super-groupes
{
    compte_chelicerata = 0
    compte_hexapoda = 0
    compte_crustacea = 0
    compte_diplopoda = 0
    compte_chilopoda = 0

    for(i=2; i<NF; i++) {
        if($i > 0) {
            groupe_actuel = correspondance_colonne_groupe[i]
            
            if(groupe_actuel == "Chelicerata")      compte_chelicerata++
            else if(groupe_actuel == "Hexapoda")    compte_hexapoda++
            else if(groupe_actuel == "Crustacea")   compte_crustacea++
            else if(groupe_actuel == "Diplopoda")   compte_diplopoda++
            else if(groupe_actuel == "Chilopoda")   compte_chilopoda++
        }
    }

    # Calcul des sommes taxonomiques
    compte_myriapoda = compte_diplopoda + compte_chilopoda
    compte_arthropoda = compte_chelicerata + compte_hexapoda + compte_crustacea + compte_myriapoda

    # Affichage de la ligne complete
    print $1 "\t" compte_chelicerata "\t" compte_hexapoda "\t" compte_crustacea "\t" compte_diplopoda "\t" compte_chilopoda "\t" compte_myriapoda "\t" compte_arthropoda
}' "$FICHIER_MAPPING" "$FICHIER_ORTHOFINDER" > "$FICHIER_SORTIE"