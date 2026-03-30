---
name: media-import
description: Import videos from connected iPhone/Android, convert for DaVinci Resolve, delete originals from device
argument-hint: <target videos description (e.g. "今日の動画", "昨日の4K動画")>
---

# Media Import

Import video files from connected mobile devices, convert audio for DaVinci Resolve Studio (Linux), and delete source files from devices.

## Arguments

```
/media-import <target description>
```

- `target description`: Natural language description of which videos to transfer (e.g. "今日の動画", "3/28の動画")

## Destination

Current working directory.

## Procedure

### STEP 1: Detect Devices

```bash
lsusb
```

Identify connected devices:
- **iPhone**: `Apple, Inc.` vendor (ID `05ac:`)
- **Android**: Known Android vendor IDs or device-specific identification

If no devices found, report and stop.

### STEP 2: Mount / Connect

#### iPhone

Requires: `usbmuxd`, `libimobiledevice`, `ifuse`

```bash
# Ensure usbmuxd is running
sudo systemctl start usbmuxd
# Wait for device recognition
sleep 3

# List devices
idevice_id -l

# Pair each device (user must have tapped "Trust" on iPhone)
idevicepair pair -u <UDID>

# Mount via AFC
mkdir -p /tmp/iphone-<UDID>
ifuse /tmp/iphone-<UDID> -u <UDID>
```

Video files are under `/tmp/iphone-<UDID>/DCIM/`.

#### Android

Requires: `adb`

```bash
# List connected devices
adb devices

# Video files are typically under:
#   /sdcard/DCIM/Camera/
#   /sdcard/Movies/
# List with:
adb -s <SERIAL> shell ls /sdcard/DCIM/Camera/
```

### STEP 3: Find Target Videos

Based on the user's target description, find matching video files.

**iPhone (mounted via ifuse):**
```bash
find /tmp/iphone-<UDID>/DCIM -type f \( -iname "*.mov" -o -iname "*.mp4" -o -iname "*.m4v" \) -newermt "<start_date>" ! -newermt "<end_date>"
```

**Android (via adb):**
```bash
# List files with timestamps
adb -s <SERIAL> shell find /sdcard/DCIM /sdcard/Movies -type f \( -iname "*.mov" -o -iname "*.mp4" -o -iname "*.mkv" \) -newermt "<start_date>" ! -newermt "<end_date>"
```

Show the user what was found (filename, size, timestamp) before proceeding.

### STEP 4: Transfer

**iPhone:**
```bash
cp /tmp/iphone-<UDID>/DCIM/.../<file> <destination>/<file>
```

**Android:**
```bash
adb -s <SERIAL> pull <remote_path> <destination>/<file>
```

For large files (>1GB), run transfers in background and report progress.

### STEP 5: Convert for DaVinci Resolve

Linux版DaVinci ResolveはAACデコードライセンスを含まないため、音声をPCMに変換する。

```bash
ffmpeg -i <original> -c:v copy -c:a pcm_s16le -map 0:v -map 0:a <output>
```

- Video: stream copy (no re-encode)
- Audio: AAC → PCM (Linear PCM, 16-bit)
- Keep original with `-original` suffix
- Converted file takes the original name

```bash
mv <file>.mov <file>-original.mov
mv <file>-pcm.mov <file>.mov
```

Run multiple conversions in parallel.

### STEP 6: Delete Source from Device

After transfer and conversion are verified:

**iPhone:**
```bash
rm /tmp/iphone-<UDID>/DCIM/.../<file>
```

**Android:**
```bash
adb -s <SERIAL> shell rm <remote_path>
```

### STEP 7: Unmount / Cleanup

**iPhone:**
```bash
fusermount -u /tmp/iphone-<UDID>
rmdir /tmp/iphone-<UDID>
```

**Android:**
No unmount needed for adb.

## Required Packages

| Package | Purpose | Install |
|---------|---------|---------|
| usbmuxd | iPhone USB multiplexing | `sudo pacman -S usbmuxd` |
| libimobiledevice | iPhone communication | `sudo pacman -S libimobiledevice` |
| ifuse | iPhone filesystem mount | `sudo pacman -S ifuse` |
| adb | Android Debug Bridge | `sudo pacman -S android-tools` |
| ffmpeg | Audio conversion | `sudo pacman -S ffmpeg` |

Install missing packages as needed (confirm with user).

## Notes

- iPhone must be unlocked and "Trust This Computer" must be accepted before mounting
- Android must have USB debugging enabled in Developer Options
- If `idevice_id -l` returns empty after pairing, restart usbmuxd
- PTP mode shows limited files; always use AFC (ifuse) for iPhone
- USB 2.0 transfers ~40MB/s; large files take time
