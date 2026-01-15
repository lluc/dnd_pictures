#!/bin/bash

# Script to copy V2 monster images to the project
# V2 images are organized in 9 D&D categories

SOURCE="/home/luc/ai-image-generator/outputs/dnd/monster"
DEST="/home/luc/projets/dnd_pictures/pictures_v2/monsters"

echo "Copying V2 monster images..."

# List of V2 categories
categories=("bêtes" "célestes" "divers" "dragons" "élémentaires" "fées" "fiélons" "humanoïdes" "morts-vivants")

total=0
for category in "${categories[@]}"; do
    mkdir -p "$DEST/$category"
    count=$(ls "$SOURCE/$category"/*.png 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        cp "$SOURCE/$category"/*.png "$DEST/$category/"
        echo "  $category: $count images"
        total=$((total + count))
    fi
done

echo ""
echo "Total: $total images copied"
