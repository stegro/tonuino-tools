#!/bin/bash

DOWNLOAD_URL=https://tonuino.github.io/TonUINO-TNG/sd-card.zip
if [ -d sd-card ]
then
    echo "The folder sd-card/ exists already."
    echo "The sd-card archive from $DOWNLOAD_URL could not be extracted,"
    echo "because it contains such an sd-card folder."
else
    wget -nc $DOWNLOAD_URL 
    unzip sd-card.zip -d "$(dirname "$0")"
    rm -vf sd-card.zip
fi
