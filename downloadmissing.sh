#!/bin/bash

while IFS= read -r line
do
  while ! adb get-state 1>/dev/null 2>&1; do
    adb reconnect
    sleep 2  # Warten für 2 Sekunden, bevor erneut geprüft wird
  done
  adb pull $line

  id2=$(echo "$line" | cut -d' ' -f2)
  echo "$id2"
  id=$(echo "$line" | awk -F' ' '{print $NF}')
  echo "$id"
  if [ -e "$id" ]; then
    echo "$line" >> "missing_new.txt"
  fi
done < "missing.txt"

#rm missing.txt
#mv missing_new.txt missing.txt
