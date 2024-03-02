#!/bin/bash

# This script uses the socalled "collection folder" as its input
# and the "sd-card folder" as output.
# By default these are ./collection and ./sd-card with respect to
# the location of this script here.

COLLECTION_FOLDER="$(dirname "$0" )/collection"
SD_CARD_FOLDER="$(dirname "$0" )/sd-card"
# information about which file in the sd-card folder corresponds to which file in the collection folder
# will be written to the following mapping info file:
MAPPING_INFO_FILE="$SD_CARD_FOLDER/mapping_info.txt"

#
# The purpose of this script is to create folders in the sd-card folder, and to populate them with hardlinks to the
# respective files in the collection folder.
# This way, there is only little diskspace wasted, because no large files are duplicated.
# Moreover, the information in folder names and file names in the collection folder is kept,
# while the sd-card folder contains only files and folders with numeric names,
# as necessary for the TonUINO firmware.
#
# ######### About the collection folder ################
#
# The collection folder is a place where albums can be grouped.
#
# The collection folder is a folder with the following structure:
# On the root, it contains what i call index folders. These are
# folders whose name is a two digit consequtive number (as demanded by the TonUINO firmware).
# Other folders are allowed to exist, but are ignored.
#
# collection/01
# collection/02
# collection/03
# ....
#
# Each of these may contain an arbitrary tree of folders containing files.
# Only the mp3 files will be considered here.
# IMPORTANT: Wherever I have written "folder" here, a symlink can also be used.
# This way, the index folders only contain some symlinks to albums which are actually stored elsewhere.
#
# Example:
#
# collection/01/PumucklFolder/episode01.mp3
# collection/01/PumucklFolder/some other episode.mp3
# collection/02/OtherSymlinkToAlbumSomewhere/wherever.mp3
# collection/02/SymlinkToAlbumSomewhere/whatever.mp3
#
#
# ######## About the sd-card folder #######################
#
# The sd-card folder is a folder which represents the data to be copied to a real sd-card.
# IMPORTANT: this is not the folder where an sd-card is mounted!
# This is just a folder whose contents can be copied to an actual SD-Card in a second step!
#
# IMPORTANT: This script will (currently) not copy any mp3/ and advert/ needed by the TonUINO folders to the sd-card folder.
# You must put these manually if you need them there.
#
# This script will generate the same index folders as present in the collection folder.
# Inside an index folder, it will create hardlinks to the mp3 files which are found in the tree in the collection folder.
# Example:
#
# sd-card/01/001.mp3    (hardlink to collection/01/PumucklFolder/episode01.mp3)
# sd-card/01/002.mp3    (hardlink to collection/01/PumucklFolder/some other episode.mp3)
# sd-card/02/001.mp3    (hardlink to collection/02/OtherSymlinkToAlbumSomewhere/wherever.mp3)
# sd-card/02/002.mp3    (hardlink to collection/02/SymlinkToAlbumSomewhere/whatever.mp3)
#
# Note that paths inside each index folder are sorted alphabetically with a little intelligence for
# numbers (using sort --version-sort).
#

shopt -s nullglob

if [ ! -d "$COLLECTION_FOLDER" ]
then
    echo "Error:"
    echo "The collection folder could not be found at"
    echo "$COLLECTION_FOLDER"
    echo "I will now create it for you..."
    mkdir -v "$COLLECTION_FOLDER"
    echo "Please populate it manually now. Instructions can be found in the file $0 ."
    exit 1
fi

mkdir -pv "$SD_CARD_FOLDER"

rm -vf "$MAPPING_INFO_FILE"

# first, remove all index folders (01, 02, ..., 99) from the sd-card folder
echo "Cleanup existing files in the sd-card folder: " "$SD_CARD_FOLDER"/[0-9][0-9]
rm -vrI "$SD_CARD_FOLDER"/[0-9][0-9]

if [ "$(echo "$COLLECTION_FOLDER"/[0-9][0-9] | wc -w)" -eq 0 ]
then
    echo "There are currently no folders with two-digit name inside $COLLECTION_FOLDER ."
    echo "Please create such folders inside $COLLECTION_FOLDER and add content like "
    echo "album folders, mp3 files or links or symlinks to such.."
    echo "For more instructions, please read $0 "
    exit 1
fi

for indexFolder in "$COLLECTION_FOLDER"/[0-9][0-9]
do
    # create the index folder in the sd-card folder.
    sdcardIndexFolder="$SD_CARD_FOLDER/$(basename "$indexFolder")"
    mkdir -vp "$sdcardIndexFolder"

    # In the following it will be populated with hardlinks to the mp3 files.

    i=1
    # if needed, use special arguments for the sort command
    find -L "$indexFolder" -type f -iname '*.mp3' | sort --version-sort | while read mp3File
    do
        if [ $i -gt 999 ]
        then
            echo "Error:"
            echo "$indexFolder"
            echo "contains more than 999 files. This is not allowed by the TonUINO firmware."
            echo "The last file (number 999) was:"
            echo "$mp3File"
            exit 1
        fi

        linkName="$(printf "$sdcardIndexFolder/%03d.mp3" $i)"

        # create a hardlink to the file in the collection.
        # We do not copy the file because a hardlink does not consume significant diskspace.
        ln -v "$mp3File" "$linkName" | tee --append "$MAPPING_INFO_FILE"

        i=$(($i + 1))
    done
done
