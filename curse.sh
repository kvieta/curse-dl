#!/bin/bash
if [ -z "$1" ]
  then
    echo "Specify a modpack zip."
    exit 1
elif [[ "$1" == *http*zip* ]]
  then
    echo "Installing modpack from $1"
    echo "Link given. Downloading modpack..."
    wget -q --show-progress "$1"
    zip=$(echo $1 | awk -F '/' '{ print $(NF) }' | sed 's/%20/ /g')
elif [[ "$1" == *\.zip* ]] && [ -d $1 ]
  then
    echo "Installing modpack from $1"
    echo "Local file detected."
    zip="$1"
else
    echo "Don't know what to do with \"$1\", does it exist?"
    exit 1
fi

xdir="$(echo $zip | sed 's/.zip//')"


unzip -q "$zip" -d "$xdir" && rm "$zip"

#getmod $modid $fileid
function getmod {
  modurl=$(curl -A "kvieta-curse-dl" -s "https://cursemeta.dries007.net/$1/files.json" | sed 's/}/}\n/g' | grep "$2" | xargs | tr ',' '\n' | grep Download | sed 's/DownloadURL://')
  wget -q --show-progress --no-clobber "$modurl"
}

cd "$xdir"
mkdir cursemods
cd cursemods

#bash is turing complete
mod_arr=( $(grep 'projectID\|fileID' ../manifest.json | sed '1~2 s/,//' | tr '\n' ',' | sed 's/"//g;s/projectID:/_/g;s/fileID://g;s/,,//g;s/ //g' | tr "_" "\n") )
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
mv cursemods/* "minecraft/mods/"
rmdir cursemods overrides && rm modlist.html

#todo: option to write instance.cfg and copy into multimc instance dir
