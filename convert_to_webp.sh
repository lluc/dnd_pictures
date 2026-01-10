#!/bin/bash

# Script de conversion PNG vers WEBP
# Convertit toutes les images PNG du répertoire pictures/ vers pictures_webp/
# en conservant la structure des sous-répertoires (récursif)
# Ne convertit que les images qui n'ont pas encore de WEBP correspondant

SOURCE_DIR="pictures"
DEST_DIR="pictures_webp"
QUALITY=80

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Conversion PNG vers WEBP ===${NC}"
echo ""

# Créer le répertoire destination principal
mkdir -p "$DEST_DIR"

# Compteurs globaux
total_converted=0
total_skipped=0
total_files=0

# Collecter tous les fichiers PNG récursivement
mapfile -t png_files < <(find "$SOURCE_DIR" -type f -name "*.png" | sort)
total_files=${#png_files[@]}

echo -e "Analyse de $total_files fichiers PNG..."
echo ""

# Variables pour le suivi par répertoire
current_dir=""
dir_count=0
dir_total=0
dir_converted=0

for png_file in "${png_files[@]}"; do
    # Calculer le chemin relatif et destination
    relative_path="${png_file#$SOURCE_DIR/}"
    dest_file="$DEST_DIR/${relative_path%.png}.webp"
    file_dir=$(dirname "$relative_path")

    # Nouveau répertoire ? Afficher le résumé du précédent
    if [ "$file_dir" != "$current_dir" ]; then
        # Afficher résumé du répertoire précédent
        if [ -n "$current_dir" ] && [ $dir_total -gt 0 ]; then
            if [ $dir_converted -gt 0 ]; then
                echo -e "\r  ${GREEN}✓ $dir_converted converti(s)${NC}, $((dir_total - dir_converted)) existant(s)                    "
            else
                echo -e "\r  ${YELLOW}○ Tous existants ($dir_total)${NC}                    "
            fi
        fi

        current_dir="$file_dir"
        dir_count=0
        dir_total=$(find "$SOURCE_DIR/$file_dir" -maxdepth 1 -type f -name "*.png" 2>/dev/null | wc -l)
        dir_converted=0

        echo -e "${BLUE}[$file_dir]${NC} - $dir_total images"
    fi

    ((dir_count++))
    filename=$(basename "$png_file" .png)

    # Créer le répertoire destination si nécessaire
    mkdir -p "$(dirname "$dest_file")"

    # Convertir seulement si le WEBP n'existe pas
    if [ ! -f "$dest_file" ]; then
        printf "\r  (%d/%d) Converting: %s" "$dir_count" "$dir_total" "$filename.png"

        # Convertir avec ImageMagick
        convert "$png_file" -quality "$QUALITY" "$dest_file"

        ((total_converted++))
        ((dir_converted++))
    else
        printf "\r  (%d/%d) Skipped: %s" "$dir_count" "$dir_total" "$filename.png"
        ((total_skipped++))
    fi
done

# Afficher résumé du dernier répertoire
if [ -n "$current_dir" ] && [ $dir_total -gt 0 ]; then
    if [ $dir_converted -gt 0 ]; then
        echo -e "\r  ${GREEN}✓ $dir_converted converti(s)${NC}, $((dir_total - dir_converted)) existant(s)                    "
    else
        echo -e "\r  ${YELLOW}○ Tous existants ($dir_total)${NC}                    "
    fi
fi

echo ""
echo -e "${GREEN}=== Conversion terminée ===${NC}"
echo "Total: $total_files fichiers analysés"
echo -e "  ${GREEN}$total_converted converti(s)${NC}"
echo -e "  ${YELLOW}$total_skipped existant(s) (ignorés)${NC}"
echo ""

# Afficher la comparaison des tailles
echo "Taille des répertoires:"
du -sh "$SOURCE_DIR" "$DEST_DIR" 2>/dev/null
