#!/bin/bash
# Script de copie et mapping des images V2 vers la structure V1
# Copie les images depuis /home/luc/ai-image-generator/outputs/dnd/equipment/
# vers pictures_v2/equipment/ en respectant la structure de sous-catégories V1

SOURCE_V2="/home/luc/ai-image-generator/outputs/dnd/equipment"
DEST_V2="pictures_v2/equipment"
V1_REF="pictures/equipment"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Copie et Mapping des Images V2 ===${NC}"
echo ""

# Compteurs
total_copied=0
total_not_found=0
not_found_files=""

# Fonction pour trouver la sous-catégorie V1 correspondante
find_v1_subcategory() {
    local filename="$1"

    # Chercher dans chaque sous-catégorie V1
    for subcat_dir in "$V1_REF"/*/; do
        subcat=$(basename "$subcat_dir")
        if [ -f "$subcat_dir/$filename" ]; then
            echo "$subcat"
            return 0
        fi
    done

    return 1
}

# Parcourir toutes les images V2
echo -e "${BLUE}Analyse des images V2...${NC}"
echo ""

for v2_subdir in "$SOURCE_V2"/*/; do
    v2_subcat=$(basename "$v2_subdir")

    # Ignorer le répertoire test
    if [ "$v2_subcat" = "test" ]; then
        continue
    fi

    echo -e "${YELLOW}[$v2_subcat]${NC}"

    for v2_file in "$v2_subdir"*.png; do
        if [ ! -f "$v2_file" ]; then
            continue
        fi

        filename=$(basename "$v2_file")

        # Trouver la sous-catégorie V1 correspondante
        v1_subcat=$(find_v1_subcategory "$filename")

        if [ -n "$v1_subcat" ]; then
            # Copier vers la bonne sous-catégorie V1
            cp "$v2_file" "$DEST_V2/$v1_subcat/"
            ((total_copied++))
            printf "\r  Copié: %-50s -> %s" "$filename" "$v1_subcat"
        else
            ((total_not_found++))
            not_found_files="$not_found_files\n  - $filename (from $v2_subcat)"
        fi
    done

    echo ""
done

echo ""
echo -e "${GREEN}=== Copie terminée ===${NC}"
echo -e "Total copié: ${GREEN}$total_copied${NC} fichiers"

if [ $total_not_found -gt 0 ]; then
    echo -e "Non trouvés dans V1: ${RED}$total_not_found${NC} fichiers"
    echo -e "${YELLOW}Fichiers non mappés:${NC}$not_found_files"
fi

echo ""
echo "Vérification des répertoires destination:"
for subcat_dir in "$DEST_V2"/*/; do
    subcat=$(basename "$subcat_dir")
    count=$(find "$subcat_dir" -type f -name "*.png" 2>/dev/null | wc -l)
    if [ $count -gt 0 ]; then
        echo -e "  ${GREEN}$subcat${NC}: $count images"
    fi
done
