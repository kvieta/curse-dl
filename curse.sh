#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "Specify a modpack zip."
    exit 1
fi

echo "Installing modpack from $1"
XDIR="$(echo $1 |sed 's/.zip//')"
#echo "debug: XDIR=\"$XDIR\""

unzip -q "$1" -d "$XDIR"

#getmod $modid $fileid
function getmod {
#  echo "debug: $0 $1 $2 $3"
  modurl=$(curl -A "kvieta-curse-dl" -s "https://cursemeta.dries007.net/$1/files.json" | sed 's/}/}\n/g' | grep "$2" | xargs | tr ',' '\n' | grep Download | sed 's/DownloadURL://')
#  echo "debug: $modurl"
  wget -q --show-progress --no-clobber "$modurl"
}

cd "$XDIR"
mkdir cursemods
cd cursemods

#bash is turing complete
mod_arr=( $(grep 'projectID\|fileID' ../manifest.json | sed '1~2 s/,//' | tr '\n' ' '| xargs | tr ',' '\n' | sed 's/projectID://g;s/fileID:/,/g;s/ //g') )
mod_arr_length=${#mod_arr[@]}
for (( i=0; i<${mod_arr_length}+1; i++ ));
  do
    getmod $(echo ${mod_arr[$i]} | sed 's/,/ /')
done

cd ..

#merge curse mods with overrides
mkdir minecraft

if [ -d "overrides/mods" ]
  then
    mv overrides/mods minecraft/
  else
    mkdir minecraft/mods
    echo "Modpack does not provide additional mods"
fi
if [ -d "overrides/config" ]
  then
    mv overrides/config minecraft/
  else
    echo "Modpack does not provide configs"
fi
mv "cursemods/*" "minecraft/mods/"

#todo: option to write instance.cfg and copy into multimc instance dir
