#!/bin/bash

# BSDs don't have readlink -f
read_link()
{
   TARGET_FILE="$1"
   cd $(dirname "$TARGET_FILE")
   TARGET_FILE=$(basename "$TARGET_FILE")

   while [ -L "$TARGET_FILE" ]
   do
      TARGET_FILE=$(readlink "$TARGET_FILE")
      cd $(dirname "$TARGET_FILE")
      TARGET_FILE=$(basename "$TARGET_FILE")
   done

   PHYS_DIR=$(pwd -P)
   RESULT="$PHYS_DIR/$TARGET_FILE"
   echo $RESULT
}

SCRIPT=$(read_link "$0")
echo "Script: $SCRIPT"
BASE_DIR=$(dirname "$SCRIPT")
RDB_DIR="$BASE_DIR/dist/rdb"
LIBRETRODB_BASE_DIR=libretrodb
LIBRETRODATABASE_DAT_DIR=$BASE_DIR/libretro-database/dat
LIBRETRODATABASE_METADAT_DIR=$BASE_DIR/libretro-database/metadat

die()
{
   echo $1
   #exit 1
}

mkdir -p "$RDB_DIR"

build_libretrodb() {
   cd $BASE_DIR
   if [ -d "$LIBRETRODB_BASE_DIR" ]; then
      echo "=== Building libretrodb ==="
      cd ${LIBRETRODB_BASE_DIR}/

      if [ -z "${NOCLEAN}" ]; then
         make -j$JOBS clean || die "Failed to clean ${2}"
      fi
      make -j$JOBS || die "Failed to build ${2}"
   fi
}

# $1 is name
# $2 is match key
build_libretro_database_meta() {
   cd $BASE_DIR
   if [ -d "$LIBRETRODB_BASE_DIR" ]; then
      echo "=== Building ${1} ==="
      cd ${LIBRETRODB_BASE_DIR}/
      ./dat_converter db.rdb "${2}" "${LIBRETRODATABASE_DAT_DIR}/${1}.dat" "${LIBRETRODATABASE_METADAT_DIR}/${1}.dat"
      if [ -f "db.rdb" ]; then
         mv db.rdb "${RDB_DIR}/${1}.rdb"
      fi
   fi
}

# $1 is name
# $2 is match key
build_libretro_database() {
   cd $BASE_DIR
   if [ -d "$LIBRETRODB_BASE_DIR" ]; then
      echo "=== Building ${1} ==="
      cd ${LIBRETRODB_BASE_DIR}/
      ./dat_converter db.rdb "${2}" "${LIBRETRODATABASE_DAT_DIR}/${1}.dat"
      if [ -f "db.rdb" ]; then
         mv db.rdb "${RDB_DIR}/${1}.rdb"
      fi
   fi
}

build_libretro_databases_meta() {
   build_libretro_database_meta "Sony - PlayStation" "rom.serial"
   build_libretro_database_meta "Nintendo - Super Nintendo Entertainment System" "rom.crc"
   build_libretro_database_meta "Atari - Jaguar" "rom.crc"
   build_libretro_database_meta "Nintendo - Virtual Boy" "rom.crc"
}

build_libretro_databases() {
   build_libretro_database "Atari - 5200" "rom.crc"
   build_libretro_database "Atari - 7800" "rom.crc"
   build_libretro_database "Atari - Lynx" "rom.crc"
   build_libretro_database "Atari - ST" "rom.crc"
   build_libretro_database "Bandai - WonderSwan" "rom.crc"
   build_libretro_database "Bandai - WonderSwan Color" "rom.crc"
   build_libretro_database "Casio - Loopy" "rom.crc"
   build_libretro_database "Casio - PV-1000" "rom.crc"
   build_libretro_database "Coleco - ColecoVision" "rom.crc"
   build_libretro_database "Emerson - Arcadia 2001" "rom.crc"
   build_libretro_database "Entex - Adventure Vision" "rom.crc"
   build_libretro_database "Epoch - Super Cassette Vision" "rom.crc"
   build_libretro_database "Fairchild - Channel F" "rom.crc"
   build_libretro_database "Funtech - Super Acan" "rom.crc"
   build_libretro_database "GamePark - GP32" "rom.crc"
   build_libretro_database "GCE - Vectrex" "rom.crc"
   build_libretro_database "Hartung - Game Master" "rom.crc"
   build_libretro_database "LeapFrog - Leapster Learning Game System" "rom.crc"
   build_libretro_database "Magnavox - Odyssey2" "rom.crc"
   build_libretro_database "Microsoft - MSX" "rom.crc"
   build_libretro_database "Microsoft - MSX 2" "rom.crc"
   build_libretro_database "NEC - PC Engine - TurboGrafx 16" "rom.crc"
   build_libretro_database "NEC - Super Grafx" "rom.crc"
   build_libretro_database "Nintendo - Famicom Disk System" "rom.crc"
   build_libretro_database "Nintendo - Game Boy" "rom.crc"
   build_libretro_database "Nintendo - Game Boy Advance" "rom.crc"
   build_libretro_database "Nintendo - Game Boy Advance (e-Cards)" "rom.crc"
   build_libretro_database "Nintendo - Game Boy Color" "rom.crc"
   build_libretro_database "Nintendo - Nintendo 3DS" "rom.crc"
   build_libretro_database "Nintendo - Nintendo 3DS (DLC)" "rom.crc"
   build_libretro_database "Nintendo - Nintendo 64" "rom.crc"
   build_libretro_database "Nintendo - Nintendo DS Decrypted" "rom.crc"
   build_libretro_database "Nintendo - Nintendo DS (Download Play) (BETA)" "rom.crc"
   build_libretro_database "Nintendo - Nintendo DSi Decrypted" "rom.crc"
   build_libretro_database "Nintendo - Nintendo DSi (DLC)" "rom.crc"
   build_libretro_database "Nintendo - Nintendo Entertainment System" "rom.crc"
   build_libretro_database "Nintendo - Nintendo Wii (DLC)" "rom.crc"
   build_libretro_database "Nintendo - Pokemon Mini" "rom.crc"
   build_libretro_database "Nintendo - Satellaview" "rom.crc"
   build_libretro_database "Nintendo - Sufami Turbo" "rom.crc"
   build_libretro_database "Philips - Videopac+" "rom.crc"
   build_libretro_database "RCA - Studio II" "rom.crc"
   build_libretro_database "Sega - 32X" "rom.crc"
   build_libretro_database "Sega - Game Gear" "rom.crc"
   build_libretro_database "Sega - Master System - Mark III" "rom.crc"
   build_libretro_database "Sega - Mega Drive - Genesis" "rom.crc"
   build_libretro_database "Sega - PICO" "rom.crc"
   build_libretro_database "Sega - SG-1000" "rom.crc"
   build_libretro_database "Sinclair - ZX Spectrum +3" "rom.crc"
   build_libretro_database "SNK - Neo Geo Pocket" "rom.crc"
   build_libretro_database "SNK - Neo Geo Pocket Color" "rom.crc"
   build_libretro_database "Sony - PlayStation 3 (DLC)" "rom.crc"
   build_libretro_database "Sony - PlayStation 3 (Downloadable)" "rom.crc"
   build_libretro_database "Sony - PlayStation 3 (PSN)" "rom.crc"
   build_libretro_database "Sony - PlayStation Portable" "rom.crc"
   build_libretro_database "Sony - PlayStation Portable (DLC)" "rom.crc"
   build_libretro_database "Sony - PlayStation Portable (PSX2PSP)" "rom.crc"
   build_libretro_database "Sony - PlayStation Portable (UMD Music)" "rom.crc"
   build_libretro_database "Sony - PlayStation Portable (UMD Video)" "rom.crc"
   build_libretro_database "Tiger - Game.com" "rom.crc"
   build_libretro_database "VTech - CreatiVision" "rom.crc"
   build_libretro_database "VTech - V.Smile" "rom.crc"
   build_libretro_database "Watara - Supervision" "rom.crc"
}

build_libretrodb
build_libretro_databases_meta
build_libretro_databases
