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
build_libretro_database() {
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

build_libretro_databases() {
   build_libretro_database "Sony - PlayStation" "rom.serial"
   build_libretro_database "Nintendo - Super Nintendo Entertainment System" "rom.crc"
}

build_libretrodb
build_libretro_databases
