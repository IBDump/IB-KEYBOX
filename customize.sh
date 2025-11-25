# Allow a scripts-only mode for older Android (<10) which may not require the Zygisk components
if [ -f /data/adb/modules/playintegrityfix/scripts-only-mode ]; then
    ui_print "! Installing global scripts only; Zygisk attestation fallback and device spoofing disabled"
    touch $MODPATH/scripts-only-mode
    sed -i 's/\(description=\)\(.*\)/\1[Scripts-only mode] \2/' $MODPATH/module.prop
    [ -f /data/adb/modules/playintegrityfix/uninstall.sh ] && sh /data/adb/modules/playintegrityfix/uninstall.sh
    rm -rf $MODPATH/action.sh $MODPATH/app_replace_list.txt \
        $MODPATH/autopif2.sh $MODPATH/classes.dex \
        $MODPATH/common_setup.sh $MODPATH/custom.app_replace_list.txt \
        $MODPATH/custom.pif.json $MODPATH/custom.pif.prop  \
        $MODPATH/example.pif.json $MODPATH/example.pif.prop $MODPATH/migrate.sh \
        $MODPATH/pif.json $MODPATH/pif.prop $MODPATH/zygisk \
        /data/adb/modules/playintegrityfix/custom.app_replace_list.txt \
        /data/adb/modules/playintegrityfix/custom.pif.json \
        /data/adb/modules/playintegrityfix/custom.pif.prop \
        /data/adb/modules/playintegrityfix/skippersistprop \
        /data/adb/modules/playintegrityfix/system \
        /data/adb/modules/playintegrityfix/uninstall.sh
fi

# Copy any disabled app files to updated module
if [ -d /data/adb/modules/playintegrityfix/system ]; then
    ui_print "- Restoring disabled ROM apps configuration"
    cp -afL /data/adb/modules/playintegrityfix/system $MODPATH
fi

# Copy any supported custom files to updated module
for FILE in custom.app_replace_list.txt custom.pif.json custom.pif.prop skipdelprop skippersistprop uninstall.sh; do
    if [ -f "/data/adb/modules/playintegrityfix/$FILE" ]; then
        ui_print "- Restoring $FILE"
        cp -af /data/adb/modules/playintegrityfix/$FILE $MODPATH/$FILE
    fi
done

# Warn if potentially conflicting modules are installed
if [ -d /data/adb/modules/MagiskHidePropsConf ]; then
    ui_print "! MagiskHidePropsConfig (MHPC) module may cause issues with PIF"
fi

# Run common tasks for installation and boot-time
if [ -d "$MODPATH/zygisk" ]; then
    . $MODPATH/common_func.sh
    . $MODPATH/common_setup.sh
fi

# Migrate custom.pif.json to latest defaults if needed
if [ -f "$MODPATH/custom.pif.json" ]; then
    if ! grep -q "api_level" $MODPATH/custom.pif.json || ! grep -q "verboseLogs" $MODPATH/custom.pif.json || ! grep -q "spoofVendingFinger" $MODPATH/custom.pif.json; then
        ui_print "- Running migration script on custom.pif.json:"
        ui_print " "
        chmod 755 $MODPATH/migrate.sh
        sh $MODPATH/migrate.sh --install --force --advanced $MODPATH/custom.pif.json
        ui_print " "
    fi
fi



#!/system/bin/sh
##########################################
# adapted from Play Integrity Fork by @osm0sis
# source: https://github.com/osm0sis/PlayIntegrityFork
# license: GPL-3.0
##########################################

ui_print "##########################################"
ui_print "             ✦🔥 Welcome! ✦🔥             "
ui_print "          🧠 Mod By @IBDump @Samy 🧠       "
ui_print "##########################################"
ui_print ""

ui_print "------------------------------------------"
ui_print "              ✦🔥 Update ✦🔥              "
ui_print "   🌐 https://github.com/IBDump/IB-KEYBOX/  "
ui_print "------------------------------------------"
ui_print ""

ui_print "******************************************"
ui_print "        📱 Telegram: https://t.me/malak_root"
ui_print "               @ibrahim_bd1               "
ui_print "******************************************"
ui_print ""

# Installation done message
ui_print ""
ui_print "✅✅✅ Installation Complete! ✅✅✅"
ui_print "      🎉 Enjoy using IB-KEYBOX! 🎉      "
ui_print ""


ui_print "# End Play integrity Script ⭐"

#!/system/bin/sh

# ---------- Device Info ----------
device_model=$(getprop ro.product.model)
android_version=$(getprop ro.build.version.release)
api_level=$(getprop ro.build.version.sdk)

ui_print "📱 Device: $device_model"
ui_print "📦 Android: $android_version (API $api_level)"
ui_print ""

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SECURITY_PATCH] $1"
}

# ---------- Cleanup Tricky Store (run as root) ----------
su -c "rm -rf /data/adb/modules/IB-KEYBOX
rm -f /data/adb/boot_hash
rm -rf /data/adb/tricky_store && mkdir -p /data/adb/tricky_store && chmod 700 /data/adb/tricky_store"

STORE_DIR="/data/adb/tricky_store"
sp="$STORE_DIR/security_patch.txt"

# ---------- Security Patch ----------
# ---------- Security Patch ----------
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SECURITY_PATCH] $1"
}

STORE_DIR="/data/adb/tricky_store"
sp="$STORE_DIR/security_patch.txt"

mkdir -p "$STORE_DIR"
chmod 700 "$STORE_DIR"

log_message "Checking Android version (API $api_level)"

if [ "$api_level" -ge 33 ]; then
  # Android 13+ → create security patch file
  current_year=$(date +%Y)
  current_month=$(date +%m)

  if [ "$current_month" -eq 1 ]; then
    prev_month=12
    prev_year=$((current_year - 1))
  else
    prev_month=$((10#$current_month - 1))
    prev_year=$current_year
  fi

  formatted_month=$(printf "%02d" $prev_month)
  echo "all=${prev_year}-${formatted_month}-05" > "$sp"

  # set permissions root:root 644
  su -c "chown 0:0 '$sp'"
  su -c "chmod 0644 '$sp'"

  log_message "✅ Security patch file created"
  ui_print "✅ Security patch file created"

else
  # Android 10–12 → skip
  [ -f "$sp" ] && su -c "rm -f '$sp'" >/dev/null 2>&1
  log_message "🟢 Security patch skipped"
  ui_print ""
fi

# ---------- KeyBox ----------
unzip -o "$ZIPFILE" 'zygisk/*' -d "$MODPATH/zygisk" > /dev/null 2>&1

if [ -f "/data/adb/tricky_store/keybox.xml" ]; then
  backup_file "$CONFIG_DIR/keybox.xml"
  rm "/data/adb/tricky_store/keybox.xml"
fi

random_keybox=$(find "$MODPATH/zygisk" -type f -name "*@Malak_Root" | shuf -n 1)
if [ -z "$random_keybox" ]; then
    abort "Error: No @Malak_Root files found"
    exit 1
fi
cp "$random_keybox" "/data/adb/tricky_store/keybox.xml"
su -c "chown 0:0 '/data/adb/tricky_store/keybox.xml' >/dev/null 2>&1 || true"
su -c "chmod 0644 '/data/adb/tricky_store/keybox.xml' >/dev/null 2>&1 || true"

su -c killall com.google.android.gms
su -c killall com.google.android.gms.unstable

# ---------- Bootloader & Spoofer ----------
SAFE_MODE=0
KILL_PKG="com.android.vending"

# ---------- helpers ----------
append_unique() { # append_unique <file> <line>
  local f="$1" line="$2"
  [ -f "$f" ] || touch "$f"
  grep -qxF "$line" "$f" 2>/dev/null || echo "$line" >>"$f"
}

pkg_exists() { # pkg_exists <package.name>
  pm list packages "$1" 2>/dev/null | grep -q "^package:$1$"
}

# ---------- paths ----------
STORE_DIR="/data/adb/tricky_store"
TARGET_TXT="$STORE_DIR/target.txt"
TEE_STATUS="$STORE_DIR/tee_status"
BOOT_HASH_FILE="/data/adb/boot_hash"

mkdir -p "$STORE_DIR"
chmod 0755 "$STORE_DIR" 2>/dev/null

# ========================================================
# 1) SET_TARGET
# ========================================================
log_message "SET_TARGET Start"
teeBroken="false"
if [ -f "$TEE_STATUS" ]; then
  teeBroken=$(grep -E '^teeBroken=' "$TEE_STATUS" | cut -d= -f2 2>/dev/null || echo "false")
fi

for L in \
  "android" \
  "com.android.vending" \
  "com.google.android.gsf" \
  "com.google.android.gms" \
  "com.google.android.apps.walletnfcrel" \
  "com.openai.chatgpt" \
  "com.reveny.nativecheck" \
  "io.github.vvb2060.keyattestation" \
  "io.github.vvb2060.mahoshojo" \
  "icu.nullptr.nativetest" \
  "com.android.nativetest" \
  "io.liankong.riskdetector" \
  "me.garfieldhan.holmes" \
  "luna.safe.luna" \
  "com.zhenxi.hunter" \
  "gr.nikolasspyr.integritycheck" \
  "com.youhu.laifu" \
  "com.google.android.contactkeys" \
  "com.google.android.ims" \
  "com.google.android.safetycore" \
  "com.whatsapp" \
  "com.whatsapp.w4b"
do
  append_unique "$TARGET_TXT" "done"
done

add_packages() {
  pm list packages "$1" 2>/dev/null | cut -d: -f2 | while read -r pkg; do
    [ -n "$pkg" ] || continue
    if ! grep -q "^$pkg" "$TARGET_TXT" 2>/dev/null; then
      if [ "$teeBroken" = "true" ]; then
        append_unique "$TARGET_TXT" "$pkg"
      else
        append_unique "$TARGET_TXT" "$pkg"
      fi
    fi
  done
}

log_message "SET_TARGET Writing"
add_packages "-3"
add_packages "-s"
chmod 0644 "$TARGET_TXT" 2>/dev/null
log_message "SET_TARGET Finish"

# ========================================================
# 2) SET_BOOT_HASH
# ========================================================
log_message "SET_BOOT_HASH Start"
boot_hash=$(su -c "getprop ro.boot.vbmeta.digest" 2>/dev/null)
mkdir -p "$(dirname "$BOOT_HASH_FILE")"
if [ -n "$boot_hash" ]; then
  echo "$boot_hash" > "$BOOT_HASH_FILE"
  chmod 0644 "$BOOT_HASH_FILE"
  su -c "resetprop -n ro.boot.vbmeta.digest $boot_hash" 2>/dev/null
  log_message "SET_BOOT_HASH Finish"
else
  log_message "SET_BOOT_HASH vbmeta digest is empty"
fi

# ========================================================
# 3) KILL_GOOGLE
# ========================================================
log_message "KILL_GOOGLE Start"
if [ "$SAFE_MODE" -eq 0 ] && pkg_exists "$KILL_PKG"; then
  am force-stop "$KILL_PKG" >/dev/null 2>&1
  cmd package stop-user --user 0 "$KILL_PKG" >/dev/null 2>&1
  pm clear "$KILL_PKG" >/dev/null 2>&1
fi
log_message "KILL_GOOGLE Finish"

# ========================================================
# 4) DELETE TWRP FOLDER
# ========================================================
log_message "DELETE_TWRP Start"
if [ "$SAFE_MODE" -eq 0 ]; then
  TWRP_FOLDER="/sdcard/TWRP"
  [ -d "$TWRP_FOLDER" ] && rm -rf "$TWRP_FOLDER" >/dev/null 2>&1
fi
log_message "DELETE_TWRP Finish"

# ========================================================
# 5) Hide My Applist cleanup
# ========================================================
log_message "HMA Start"
if [ "$SAFE_MODE" -eq 0 ]; then
  FOLDERS=$(find /data/system -maxdepth 1 -type d \( -iname "*hide*" -o -iname "*hma*" -o -iname "*applist*" \) 2>/dev/null)
  if [ -n "$FOLDERS" ]; then
    for F in $FOLDERS; do rm -rf "$F" >/dev/null 2>&1; done
  fi
fi
log_message "HMA Finish"

# Start Auto Hide App Script ⭐
nohup am start -a android.intent.action.VIEW -d https://t.me/malak_root>/dev/null 2>&1 &

# Clean up any leftover files from previous deprecated methods
rm -f /data/data/com.google.android.gms/cache/pif.prop /data/data/com.google.android.gms/pif.prop \
    /data/data/com.google.android.gms/cache/pif.json /data/data/com.google.android.gms/pif.json
