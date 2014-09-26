#!/bin/bash

NEW_VERSION_CODE=$1
WORKING_PATH=$(pwd)"/patches_$NEW_VERSION_CODE"
SOURCE_PATH="$WORKING_PATH/../../../.."
VERSION_FILE="versionList.txt"
PATCH_CONFIG_FILE="patchConfig"
echo "Create patch for new version: $NEW_VERSION_CODE"
echo "Working path: $WORKING_PATH"
echo "Source path: $SOURCE_PATH"

# Make sure the target version is selected
if [ ! -n "$1" ] ;then
	echo "Error: No target version defined."
	echo "Check each version is listed in $VERSION_FILE before run."
	echo "Usage: ./PatchCreation.sh ios1.13"
	exit
fi

# Clear history
rm -rf "$WORKING_PATH"
mkdir "$WORKING_PATH"

function diffVersionWithTags()
{
	echo "Create patch from $1 to $2"
	patchDir=$WORKING_PATH/$1_$2
	mkdir "$patchDir"
	git diff --name-status $1..$2 > "$patchDir/gitDiff"

	# If a lua file is updated, we need to add the game.bin.
	luaUpdated=false
	# If code is changed, no self-update is support for this.
	codeUpdated=false

	while read -r diffInfo
	do
	    diffInfoArr=(${diffInfo//	/ })
	    status="${diffInfoArr[0]}"
	    filePath="${diffInfoArr[1]}"

	    if [ $status = "A" ] || [ $status = "M" ]; then
	    	if [[ $filePath == projects/FootballHero/Resources/scripts/* ]]; then
	    		# Check lua updates
	    		luaUpdated=true
	    	elif [[ $filePath == *.cpp ]] || [[ $filePath == *.h ]] || [[ $filePath == *.java ]] || [[ $filePath == *.mm ]] || [[ $filePath == *.m ]]; then
	    		# Check code updates
	    		codeUpdated=true
	    		break
	    	elif [[ $filePath == projects/FootballHero/Resources/CryptLuascripts/* ]]; then
	    		# Ignore some files.
	    		continue
	    	elif [[ $filePath == projects/FootballHero/Resources/game.bin ]]; then
	    		# Ignore some files.
	    		continue
	    	elif [[ $filePath == projects/FootballHero/Resources/* ]]; then
	    		# Put in resource files.
	    		shortFilePath=${filePath#projects/FootballHero/Resources/}
	    		newDir=$(dirname $patchDir/$shortFilePath)
		    	mkdir -p $newDir
		    	cp -R $SOURCE_PATH/$filePath $patchDir/$shortFilePath
	    	fi
	    fi
	done < "$patchDir/gitDiff"

	# Add the game.bin if necessary
	if [ $luaUpdated == true ]; then
		cp -R $SOURCE_PATH/projects/FootballHero/Resources/game.bin $patchDir/game.bin
	fi

	# Create the zip package and update the patchConfig.
	if [ $codeUpdated == true ]; then
		echo "Since the code is change, no self update."
		echo "$1.needUpdate = false" >> $WORKING_PATH/$PATCH_CONFIG_FILE
	else
		rm -f $patchDir/gitDiff
		cd $WORKING_PATH
		
		# Check if the patch folder is empty
		if [ "`ls -A $1_$2`" == "" ]; then
			echo "$1.needUpdate = false" >> $WORKING_PATH/$PATCH_CONFIG_FILE
		else
			cd $1_$2
			zip -r -q ../$1_$2.zip *
			cd ..
			fileSizeInfo=$(du -sh $1_$2.zip)
			fileSize=(${fileSizeInfo//	/ })
			echo "$1.needUpdate = true" >> $WORKING_PATH/$PATCH_CONFIG_FILE
			echo "$1.package = $1_$2.zip" >> $WORKING_PATH/$PATCH_CONFIG_FILE
			echo "$1.size = $fileSize" >> $WORKING_PATH/$PATCH_CONFIG_FILE
		fi
	fi

	echo "" >> $WORKING_PATH/$PATCH_CONFIG_FILE
}

while read -r v
do
    diffVersionWithTags $v $1
done < $VERSION_FILE