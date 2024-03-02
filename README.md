# TonUINO tools by DM4SG

This repository contains a couple of scripts which I use to organise content
for my [TonUINO](https://voss.earth/tonuino).

I use the [TonUINO-TNG](https://github.com/tonuino/TonUINO-TNG) firmware.

# Usage

First, execute

     ./init-sd-card-folder.sh

to download sd-card.zip from [https://github.com/tonuino/TonUINO-TNG](https://github.com/tonuino/TonUINO-TNG)
and unzip it to create a `sd-card/` folder.

Then you need to manually create a folder `collection/` and put 'index folders' (folders whose name is a two-digit number like `01`, `02`, `03` ... `99`) therein.
Inside each index folder, put a folder tree containing some mp3 files. **You may want to use symlinks to include albums which are
already stored elsewhere on your harddisks.**
For more instructions, read the the comments inside the script file `make-links.sh` .   

To fill the `sd-card/` folder from the collection folder, run

    ./make-links.sh

This will create hardlinks to all the mp3s of the collection folder, flattening any folder tree, sorting with `--version-sort`.
Only these hardlinks will have the required naming `001.mp3`, `002.mp3` etc. .


Finally, manually mount your actual SD card and copy the content of `sd-card/` to the SD card.
