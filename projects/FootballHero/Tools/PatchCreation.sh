#!/bin/bash

NEW_VERSION_CODE=$1
WORKING_PATH=$(pwd)"/patches_$NEW_VERSION_CODE"
SOURCE_PATH="$WORKING_PATH/../../../.."
VERSION_FILE="versionList.txt"
echo "Create patch for new version: $NEW_VERSION_CODE"
echo "Working path: $WORKING_PATH"
echo "Source path: $SOURCE_PATH"

if [ ! -n "$1" ] ;then
	echo "Add a target version"
	exit
fi

rm -rf "$WORKING_PATH"
mkdir "$WORKING_PATH"

function diffVersionWithTags()
{
	echo "Create patch from $1 to $2"
	patchDir=$WORKING_PATH/$1_$2
	mkdir "$patchDir"
	git diff --name-status $1..$2 > "$patchDir/gitDiff"

	luaUpdated=false
	codeUpdated=false

	while read -r diffInfo
	do
	    diffInfoArr=(${diffInfo//	/ })
	    status="${diffInfoArr[0]}"
	    filePath="${diffInfoArr[1]}"

	    if [ $status = "A" ] || [ $status = "M" ]; then
	    	

	    	if [[ $filePath == projects/FootballHero/Resources/scripts/* ]]; then
	    		luaUpdated=true
	    	elif [[ $filePath == *.cpp ]]; then
	    		codeUpdated=true
	    	elif [[ $filePath == projects/FootballHero/Resources/CryptLuascripts/* ]]; then
	    		continue
	    	elif [[ $filePath == projects/FootballHero/Resources/* ]]; then
	    		shortFilePath=${filePath#projects/FootballHero/Resources/}
	    		newDir=$(dirname $patchDir/$shortFilePath)
		    	mkdir -p $newDir
		    	cp -R $SOURCE_PATH/$filePath $patchDir/$shortFilePath
	    	fi
	    fi
	done < "$patchDir/gitDiff"

	if [ $luaUpdated ]; then
		cp -R $SOURCE_PATH/projects/FootballHero/Resources/game.bin $patchDir/game.bin
	fi
	if [ $codeUpdated ]; then
		echo "Since the code is change, no self update."
	else
		rm -f $patchDir/gitDiff
		cd $WORKING_PATH
		zip -r -q $1_$2.zip $1_$2
	fi
}

while read -r v
do
    diffVersionWithTags $v $1
done < $VERSION_FILE