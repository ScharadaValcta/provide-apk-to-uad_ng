# ADB Package Exporter

This script exports device information and installed APKs from an Android device connected via ADB. The data is organized into a folder named after the device's brand and model.

## Prerequisites
- ADB (Android Debug Bridge) must be installed.
- The Android device must be in developer mode with USB debugging enabled.
- The device must be connected via USB.

## Usage
1. Ensure your Android device is properly connected:
   ```bash
   adb devices
   ```
2. Run the script:
   ```bash
   ./adb_apl_backup.sh
   ```

## What the Script Does
1. **Collects Device Information**:
   - Reads the brand (`ro.product.brand`) and model (`ro.product.model`) of the device.
   - Creates a folder named "Brand - Model".
   - Saves device information in `device_info.txt`.

2. **Lists Installed Packages**:
   - Lists all installed packages in `full_packages.txt` (including file paths).
   - Saves only the APK file paths in `packages.txt`.
   - Generates additional lists (`unlisted_by_uad-ng.txt`) for specific filtering purposes. Currently you still have to adjust the list by hand after that please rename ```_done.txt```

3. **Exports APKs**:
   - Downloads all APK files of installed apps into the `apk` subfolder.

## Directory Structure
After running the script, a folder will be created with the following structure:

```
Brand - Model/
├── apk/
│   ├── <apk-file-1>.apk
│   ├── <apk-file-2>.apk
│   └── ...
├── device_info.txt
├── full_packages.txt
├── packages.txt
└── unlisted_by_uad-ng.txt
```

## Notes
- The script does not filter out system apps. If you only want to export user-installed apps, you will need to modify the script accordingly.
- APK files can take up significant storage space depending on the device and the number of installed apps.

## Troubleshooting
- **ADB does not recognize the device**: Ensure the device is in developer mode and USB debugging is enabled. Confirm the debugging prompt on the device.
- **Some APKs dont get downloaded**: These where the Error comes are not of interest in uad_ng.

## Aditional Links
- [How to Set Up and Use ADB over Wi-Fi (Windows & Mac)](https://technastic.com/set-up-adb-over-wifi-android/)


## License
This script is licensed under the [MIT License](https://opensource.org/licenses/MIT).

