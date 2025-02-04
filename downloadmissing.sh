#!/bin/bash

while IFS= read -r line
do
  while ! adb get-state 1>/dev/null 2>&1; do
    adb reconnect
    if ! adb get-state 1>/dev/null 2>&1; then
      (adb kill-server && adb start-server)
    fi
    sleep 2  # Warten für 2 Sekunden, bevor erneut geprüft wird
  done
  id=$(echo "$line" | awk -F' ' '{print $NF}')
  echo "$id"
  #id2=$(echo "$line" | cut -d' ' -f2)
  #echo "$id2"
  if [ -e "$id" ]; then
    echo "$id is not missing."
    continue
  else
    echo "$id is missing."
  fi

  adb pull $line

  if [ -e "$id" ]; then
    echo "$id is downloaded."
  else
    echo "$line" >> "missing_new.txt"
  fi
  echo ""
done < "missing.txt"

echo "Missing apks before: $(cat missing.txt | wc -l)"

rm missing.txt
if [ -e "missing_new.txt" ]; then
  echo "Missing apks after: $(cat missing_new.txt | wc -l)"
  echo "There are still APK-Files missing. Please run again"
  mv missing_new.txt missing.txt
else
  echo "All APK-File are there please run adb_apk_backup.sh again."
fi
