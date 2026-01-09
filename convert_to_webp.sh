#!/bin/bash

# Script de conversion PNG vers WEBP
# Convertit toutes les images PNG du répertoire pictures/ vers pictures_webp/
# en conservant la structure des sous-répertoires

SOURCE_DIR="pictures"
DEST_DIR="pictures_webp"
QUALITY=80

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Conversion PNG vers WEBP ===${NC}"
echo ""

# Créer le répertoire destination principal
mkdir -p "$DEST_DIR"

# Compteurs globaux
total_converted=0
total_files=0

# Pour chaque sous-répertoire
for subdir in "$SOURCE_DIR"/*/; do
    # Vérifier que c'est bien un répertoire
    [ -d "$subdir" ] || continue

    subdir_name=$(basename "$subdir")

    # Créer le sous-répertoire destination
    mkdir -p "$DEST_DIR/$subdir_name"

    # Compter les fichiers PNG dans ce sous-répertoire
    total=$(find "$subdir" -maxdepth 1 -name "*.png" -type f | wc -l)

    # Ignorer si pas de fichiers PNG
    [ "$total" -eq 0 ] && continue

    total_files=$((total_files + total))
    count=0

    echo -e "${BLUE}[$subdir_name]${NC} - $total images à convertir"

    # Convertir chaque fichier PNG
    for png_file in "$subdir"*.png; do
        # Vérifier que le fichier existe
        [ -f "$png_file" ] || continue

        ((count++))
        filename=$(basename "$png_file" .png)

        # Afficher la progression
        printf "\r  (%d/%d) %s" "$count" "$total" "$filename.png"

        # Convertir avec ImageMagick
        convert "$png_file" -quality "$QUALITY" "$DEST_DIR/$subdir_name/$filename.webp"

        ((total_converted++))
    done

    # Nouvelle ligne après le sous-répertoire
    echo -e "\r  ${GREEN}✓ ($count/$total) Terminé${NC}                                        "
done

echo ""
echo -e "${GREEN}=== Conversion terminée ===${NC}"
echo "Total: $total_converted/$total_files images converties"
echo ""

# Afficher la comparaison des tailles
echo "Taille des répertoires:"
du -sh "$SOURCE_DIR" "$DEST_DIR" 2>/dev/null
