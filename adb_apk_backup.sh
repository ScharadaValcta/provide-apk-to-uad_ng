#!/bin/bash

# Gerätemodell und Hersteller ermitteln
brand=$(adb shell getprop ro.product.brand | tr -d '\r')
device_model=$(adb shell getprop ro.product.model | tr -d '\r')

# Ordner mit dem Gerätenamen erstellen
OUTPUT_DIR="$brand - $device_model"
mkdir -p "$OUTPUT_DIR/apk"

# Lade die JSON-Datei herunter
curl -sL "https://raw.githubusercontent.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/main/resources/assets/uad_lists.json" -o uad_lists.json

# Extrahiere alle Paket-IDs aus der JSON-Datei in ein Array
uad_ids=$(jq -r 'keys[]' uad_lists.json)

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
# Über die Datei iterieren
while IFS= read -r line
do
  id=$(echo "$line" | awk -F'=' '{print $NF}')
  path=$(echo "$line" | sed "s/=$id$//")
  echo "ID: $id"
  echo "Path: $path"

  if ! echo "$uad_ids" | grep -q "^$id$"; then
      echo "$id" >> "../unlisted_by_uad-ng_automatic.txt"
      echo "Nicht gelistet: $id"
  else
      echo "Gelistet: $id"
  fi

  # Jede Zeile bearbeiten
  adb pull $path "$id".apk
  echo ""
done < "../full_packages.txt"

zip -r "$OUTPUT_DIR - apk.zip" "$OUTPUT_DIR/apk" 
cd ..
cd ..

#if ! echo "$uad_ids" | grep -q "^vendor.qti.hardware.cacert.server$"; then
#    echo "$id" >> unlisted.txt
#    echo "Nicht gelistet: vendor.qti.hardware.cacert.server"
#else
#    echo "Gelistet: vendor.qti.hardware.cacert.server"
#fi
