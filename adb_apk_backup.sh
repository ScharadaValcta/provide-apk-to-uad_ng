#!/usr/bin/env bash
set -euf -o pipefail

echo "Starting if a device is connected"
adb wait-for-device

# Gerätemodell und Hersteller ermitteln
brand=$(adb shell getprop ro.product.brand | tr -d '\r')
device_model=$(adb shell getprop ro.product.model | tr -d '\r')

# Ordner mit dem Gerätenamen erstellen
OUTPUT_DIR="$brand - $device_model"
mkdir -p "$OUTPUT_DIR/apk"

# Lade die JSON-Datei herunter
curl -sL "https://raw.githubusercontent.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/main/resources/assets/uad_lists.json" -o uad_lists.json

# Extrahiere alle Paket-IDs aus der JSON-Datei in ein Array
uad_ids=$(jq -r 'keys[]' ./uad_lists.json)

#Geräteinformationen exportieren
adb shell getprop | grep -E '^\[ro\.product|\[ro\.build' > "$OUTPUT_DIR/device_info.txt"
echo "Geräteinformationen wurden in $OUTPUT_DIR/device_info.txt gespeichert."

# Alle installierten Pakete auflisten
readonly all_packs
all_packs="$(adb shell pm list packages -f)"
echo "$all_packs" | grep -v "~~" | cut -d':' -f2 > "$OUTPUT_DIR/full_packages.txt"
echo "$all_packs" | grep -v base.apk | cut -d':' -f2 > "$OUTPUT_DIR/system_packages.txt"

cd "$OUTPUT_DIR/apk"
# Über die Datei iterieren
while IFS= read -r line
do
  id=$(echo "$line" | awk -F'=' '{print $NF}')
  path="${line/=$id$/}"
  printf '%s\n%s\n' "ID: $id" "Path: $path"

  if ! echo "$uad_ids" | grep -q "^$id$"; then
      echo "$id" >> "../unlisted_by_uad-ng_automatic.txt"
      echo "Nicht gelistet: $id"
  else
      echo "Gelistet: $id"
      # Überprüfe, ob die Beschreibung der ID den Text "share the apk" enthält
      if jq -e --arg id "$id" '.[$id].description | test("share the apk")' ../../uad_lists.json > /dev/null; then
          echo "$id" >> "../share_request.txt"
          echo "$id wurde in share_request.txt hinzugefügt."
      fi
  fi
  if [ -e "$id".apk ]; then
    continue  # Springt zur nächsten Zeile
  fi
  adb wait-for-device

  adb pull "$path" "$id".apk

  if [ -e "$id".apk ]; then
    echo "$path $id.apk" >> "missing.txt"
  fi

#  while [ ! -e "$id".apk ]; do
#  # Jede Zeile bearbeiten
#    adb pull $path "$id".apk
#    while ! adb get-state 1>/dev/null 2>&1; do
#      adb reconnect
#      sleep 2  # Warten für 2 Sekunden, bevor erneut geprüft wird
#    done
#  done
  echo ""
done < "../system_packages.txt"

cd ../../

zip -r "$OUTPUT_DIR - apk.zip" . -i "$OUTPUT_DIR/apk/*" 

printf '\n%s\n' "Packages found are which are unlisted or have a share request."
cat "$OUTPUT_DIR/share_request.txt" "$OUTPUT_DIR/unlisted_by_uad-ng_automatic.txt"
echo

while IFS= read -r line
do
  zip -r "$OUTPUT_DIR - unlisted or share request.zip" . -i "$OUTPUT_DIR/apk/$line.apk" 

done < "$OUTPUT_DIR/share_request.txt"

while IFS= read -r line
do
  zip -r "$OUTPUT_DIR - unlisted or share request.zip" . -i "$OUTPUT_DIR/apk/$line.apk" 

done < "$OUTPUT_DIR/unlisted_by_uad-ng_automatic.txt"

