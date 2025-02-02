#!/bin/bash

# Gerätemodell und Hersteller ermitteln
brand=$(adb shell getprop ro.product.brand | tr -d '\r')
device_model=$(adb shell getprop ro.product.model | tr -d '\r')

# Ordner mit dem Gerätenamen erstellen
OUTPUT_DIR="$brand - $device_model"
mkdir -p "$OUTPUT_DIR/apk"

#Geräteinformationen exportieren
adb shell getprop | grep -E '^\[ro\.product|\[ro\.build' > "$OUTPUT_DIR/device_info.txt"
echo "Geräteinformationen wurden in $OUTPUT_DIR/device_info.txt gespeichert."

# Alle installierten Pakete auflisten
adb shell pm list packages -f | grep -v "~~" | cut -d':' -f2 > "$OUTPUT_DIR/full_packages.txt"
adb shell pm list packages -f | grep -v "~~" | cut -d':' -f2 | cut -d'=' -f1 > "$OUTPUT_DIR/packages.txt"
adb shell pm list packages -f | grep -v "~~" | cut -d':' -f2 | cut -d'=' -f2 > "$OUTPUT_DIR/unlisted1.txt"
adb shell pm list packages -f | grep -v "~~" | cut -d':' -f2 | cut -d'=' -f3 > "$OUTPUT_DIR/unlisted2.txt"
cat "$OUTPUT_DIR/unlisted1.txt" "$OUTPUT_DIR/unlisted2.txt" | sort -u > "$OUTPUT_DIR/unlisted_by_uad-ng.txt"
rm "$OUTPUT_DIR/unlisted1.txt" "$OUTPUT_DIR/unlisted2.txt"

cd "$OUTPUT_DIR/apk"
zip "$OUTPUT_DIR - apk.zip" "$OUTPUT_DIR/apk" 
# Über die Datei iterieren
while IFS= read -r package
do
  # Jede Zeile bearbeiten
  adb pull $package 
done < "../packages.txt"
cd ..
cd ..
