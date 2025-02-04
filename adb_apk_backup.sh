#!/usr/bin/env bash

echo "Starting if a device is connected"
while ! adb get-state 1>/dev/null 2>&1; do
  adb reconnect
  if ! adb get-state 1>/dev/null 2>&1; then
    (adb kill-server && adb start-server)
  fi
  sleep 2  # Warten für 2 Sekunden, bevor erneut geprüft wird
done

# Gerätemodell und Hersteller ermitteln
brand=$(adb shell getprop ro.product.brand | tr -d '\r')
device_model=$(adb shell getprop ro.product.model | tr -d '\r')

# Ordner mit dem Gerätenamen erstellen
OUTPUT_DIR="$brand - $device_model"
mkdir -p "$OUTPUT_DIR/apk"

# Lade die JSON-Datei herunter
echo "Download of uad_list.json"
curl -sL "https://raw.githubusercontent.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/main/resources/assets/uad_lists.json" -o uad_lists.json
# TODO maybe --connect-timeout 10 and checking i uad_list.json is downloaded

# Extrahiere alle Paket-IDs aus der JSON-Datei in ein Array
echo "Loding uad_ids of uad_list.json"
uad_ids=$(jq -r 'keys[]' ./uad_lists.json)

#Geräteinformationen exportieren
adb shell getprop | grep -E '^\[ro\.product|\[ro\.build' > "$OUTPUT_DIR/device_info.txt"
echo "Geräteinformationen wurden in $OUTPUT_DIR/device_info.txt gespeichert."

# Alle installierten Pakete auflisten
all_packs="$(adb shell pm list packages -f)"
readonly all_packs
echo "$all_packs" | grep -v "~~" | cut -d':' -f2 > "$OUTPUT_DIR/full_packages.txt"
echo "$all_packs" | grep -v base.apk | cut -d':' -f2 | tr -d '\r' > "$OUTPUT_DIR/system_packages.txt"

#removing from previous pulls
if [ -f "$OUTPUT_DIR/unlisted_by_uad-ng_automatic.txt" ]; then
  rm "$OUTPUT_DIR/unlisted_by_uad-ng_automatic.txt"
fi
if [ -f "$OUTPUT_DIR/share_request.txt" ]; then
  rm "$OUTPUT_DIR/share_request.txt"
fi
if [ -f "$OUTPUT_DIR/apk/missing.txt" ]; then
  rm "$OUTPUT_DIR/apk/missing.txt"
fi

cd "$OUTPUT_DIR/apk"
# Über die Datei iterieren
while IFS= read -r line
do
  id=$(echo "$line" | awk -F'=' '{print $NF}' | tr -d '\r')
  path=$(echo "$line" | sed "s/=$id$//")
  echo "ID: $id"
  echo "Path: $path"

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
  if [ -e "$id.apk" ]; then
    echo "$id.apk already exists"
    echo ""
    continue  # Springt zur nächsten Zeile
  fi
  while ! adb get-state 1>/dev/null 2>&1; do
    adb reconnect
    if ! adb get-state 1>/dev/null 2>&1; then
      (adb kill-server && adb start-server)
    fi
    sleep 2  # Warten für 2 Sekunden, bevor erneut geprüft wird
  done

  adb pull "$path" "$id".apk
  sleep 1

  if [ -e "$id.apk" ]; then
    echo "$id.apk download successfull"
  else
    echo "$id.apk is still missing."
    echo "$path $id.apk" >> "missing.txt"
  fi
  echo ""
done < "../system_packages.txt"

cd ../../

zip -r "$OUTPUT_DIR - apk.zip" . -i "$OUTPUT_DIR/apk/*" 
echo ""

if [ -f "$OUTPUT_DIR/unlisted_by_uad-ng_automatic.txt" ]; then
  echo "Packages found which are unlisted."
  cat "$OUTPUT_DIR/unlisted_by_uad-ng_automatic.txt"
  echo ""
fi
if [ -f "$OUTPUT_DIR/share_request.txt" ]; then
  echo "Packages found which have a share request."
  cat "$OUTPUT_DIR/share_request.txt"
  echo ""
fi
if [ -f "$OUTPUT_DIR/apk/missing.txt" ]; then
  echo "Packages which cant be downloaded and are declared missing."
  cat "$OUTPUT_DIR/apk/missing.txt"
  echo ""
fi

if [ -f "$OUTPUT_DIR/share_request.txt" ]; then
  while IFS= read -r line
  do
    zip -r "$OUTPUT_DIR - unlisted or share request.zip" . -i "$OUTPUT_DIR/apk/$line.apk" 
  
  done < "$OUTPUT_DIR/share_request.txt"
fi

if [ -f "$OUTPUT_DIR/unlisted_by_uad-ng_automatic.txt" ]; then
  while IFS= read -r line
  do
    zip -r "$OUTPUT_DIR - unlisted or share request.zip" . -i "$OUTPUT_DIR/apk/$line.apk" 
  
  done < "$OUTPUT_DIR/unlisted_by_uad-ng_automatic.txt"
fi
