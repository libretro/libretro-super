#!/bin/bash
. ./libretro-config.sh

#usage:
# ./libretro-fetch-and-build.sh configfile
# if you want to force all enabled cores to rebuild prepend FORCE=YES
# you may need to specify your make command by prepending it to the commandline, for instance MAKE=mingw32-make
#
# eg: FORCE=YES MAKE=mingw32-make ./libretro-fetch-and-build.sh buildbot.conf


#build commands
build_libretro_generic_makefile() {


    DIR=$1
    SUBDIR=$2
    MAKEFILE=$3
    PLATFORM=$4
    SILENT=$5

    cd $DIR
    cd $SUBDIR
    if [ -z "${NOCLEAN}" ]; 
    then
	echo "cleaning up..."
	"${MAKE}" "${SILENT}" platform="${4}" ${COMPILER} "-j${JOBS}" clean
	if [ $? -eq 0 ];
        then 
            echo success!
        else
            echo error while cleaning up
        fi
    fi

    echo "compiling..."

    "${MAKE}" "${SILENT}" platform="${4}" ${COMPILER} "-j${JOBS}"
    if [ $? -eq 0 ];
    then 
        echo success!
    else
        echo error while compiling $1
    fi
	
}


#fetch a project and mark it for building if there have been any changes

while read line; do
    NAME=`echo $line | cut --fields=1 --delimiter=" "`
    URL=`echo $line | cut --fields=2 --delimiter=" "`
    TYPE=`echo $line | cut --fields=3 --delimiter=" "`
    ENABLED=`echo $line | cut --fields=4 --delimiter=" "`
    COMMAND=`echo $line | cut --fields=5 --delimiter=" "`
    MAKEFILE=`echo $line | cut --fields=6 --delimiter=" "`
    SUBDIR=`echo $line | cut --fields=7 --delimiter=" "`
    
    if [ "${ENABLED}" == "YES" ];
    then
        echo "Processing $NAME"
        echo ====================================
        if [ -d "${NAME}/.git" ];
        then
            cd $NAME
            echo "pulling from repo... "
            OUT=`git pull`

            if [[ $OUT == *up-to-date* ]]
            then
                BUILD="NO"
	    else
		BUILD="YES"
            fi

            cd ..

	else
            echo "cloning repo..."
            git clone --depth=1 "$URL" "$NAME"
        fi

        if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ];
	then
	    echo building core...
	    build_libretro_generic_makefile $NAME $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "-s"
	else
	    echo core already up-to-date...
	fi

    fi

done  < $1

