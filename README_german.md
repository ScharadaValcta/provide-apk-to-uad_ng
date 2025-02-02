# ADB Package Exporter

Dieses Script exportiert Geräteinformationen und installierte APKs von einem per ADB verbundenen Android-Gerät. Die Daten werden übersichtlich in einem Ordner gespeichert, der nach dem Gerätemodell und Hersteller benannt ist.

## Voraussetzungen
- ADB (Android Debug Bridge) muss installiert sein.
- Das Android-Gerät muss im Entwicklermodus sein und USB-Debugging muss aktiviert sein.
- Das Gerät muss per USB verbunden sein.

## Verwendung
1. Stelle sicher, dass dein Android-Gerät korrekt verbunden ist:
   ```bash
   adb devices
   ```
2. Führe das Script aus:
   ```bash
   ./adb_apl_backup.sh
   ```

## Was das Script macht
1. **Geräteinformationen sammeln**:
   - Hersteller (`ro.product.brand`) und Modell (`ro.product.model`) werden ausgelesen.
   - Ein Ordner mit dem Namen "Hersteller - Modell" wird erstellt.
   - Geräteinformationen werden in der Datei `device_info.txt` gespeichert.

2. **Installierte Pakete auflisten**:
   - Alle installierten Pakete werden in `full_packages.txt` gespeichert (inkl. Speicherort).
   - Nur die Speicherorte der APK-Dateien werden in `packages.txt` gespeichert.
   - Zusätzliche Listen (`unlisted_by_uad-ng.txt`) werden für spezielle Filterungen erstellt. Aktuell muss man die Liste noch per Hand anpassen. Danach bitte umbennennen mit ```_done.txt``` am Ende.

3. **APKs exportieren**:
   - Alle APK-Dateien der installierten Apps werden in den Unterordner `apk` heruntergeladen.

## Verzeichnisstruktur
Nach der Ausführung des Scripts wird ein Ordner erstellt, der wie folgt aufgebaut ist:

```
Hersteller - Modell/
├── apk/
│   ├── <apk-datei-1>.apk
│   ├── <apk-datei-2>.apk
│   └── ...
├── device_info.txt
├── full_packages.txt
├── packages.txt
└── unlisted_by_uad-ng.txt
```

## Hinweise
- Das Script filtert keine System-Apps heraus. Wenn du nur Benutzer-Apps exportieren möchtest, musst du das Script entsprechend anpassen.
- APK-Dateien können je nach Gerät und Anzahl installierter Apps viel Speicherplatz beanspruchen.

## Fehlerbehebung
- **ADB erkennt das Gerät nicht**: Stelle sicher, dass das Gerät im Entwicklermodus ist und USB-Debugging aktiviert wurde. Bestätige die Debugging-Anfrage auf dem Gerät.
- **Manche APK-Dateien werden nicht heruntergeladeǹ**: Die APK-Dateien die mit einem Error auftauchen sind für das Projekt uad_ng nicht von Interesse.

## Lizenz
Dieses Script steht unter der [MIT Lizenz](https://opensource.org/licenses/MIT).


