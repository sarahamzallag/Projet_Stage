source="/home/amzallag/stage/OrthoFinder/Results_Mar26/Orthogroups/Orthogroups.GeneCount.tsv"  # fichier OrthoFinder complet
chilodiplo="/home/amzallag/stage/analyse/chilo_diplo.tsv"  # tableau contenant seulement les 14 espèces chilo + diplo
analyse="/home/amzallag/stage/analyse"  # dossier de sortie des résultats

mkdir -p $analyse  # crée le dossier analyse s'il n'existe pas

# extrait les colonnes des 6 chilopodes et des 8 diplopodes
awk 'BEGIN{FS=OFS="\t"}{print $1,$18,$25,$26,$16,$22,$24,$17,$7,$8,$15,$5,$20,$28,$2}' $source > $chilodiplo

# sélectionne les orthogroups présents chez les 14 espèces
awk 'BEGIN{FS=OFS="\t"} NR==1{print; next} {ok=1; for(i=2;i<=15;i++) if($i==0) ok=0; if(ok) print}' $chilodiplo > $analyse/core_especes.tsv

# sélectionne les orthogroups présents chez tous les chilopodes
awk 'BEGIN{FS=OFS="\t"} NR==1{print; next} {ok=1; for(i=2;i<=7;i++) if($i==0) ok=0; if(ok) print}' $chilodiplo > $analyse/commun_chilo.tsv

# sélectionne les orthogroups présents chez tous les diplopodes
awk 'BEGIN{FS=OFS="\t"} NR==1{print; next} {ok=1; for(i=8;i<=15;i++) if($i==0) ok=0; if(ok) print}' $chilodiplo > $analyse/commun_diplo.tsv

# sélectionne les orthogroups présents chez tous les diplopodes et absents chez tous les chilopodes
awk 'BEGIN{FS=OFS="\t"} NR==1{print; next} {diplo=1; for(i=8;i<=15;i++) if($i==0) diplo=0; chilo_zero=1; for(i=2;i<=7;i++) if($i>0) chilo_zero=0; if(diplo && chilo_zero) print}' $chilodiplo > $analyse/specifi_diplo.tsv

# sélectionne les orthogroups présents chez tous les chilopodes et absents chez tous les diplopodes
awk 'BEGIN{FS=OFS="\t"} NR==1{print; next} {chilo=1; for(i=2;i<=7;i++) if($i==0) chilo=0; diplo_zero=1; for(i=8;i<=15;i++) if($i>0) diplo_zero=0; if(chilo && diplo_zero) print}' $chilodiplo > $analyse/specifi_chilo.tsv







