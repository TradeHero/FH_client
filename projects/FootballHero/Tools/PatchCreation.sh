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
if [ ! -n "$1" ]; then
	echo "Error: No target version defined."
	echo "Check each version is listed in $VERSION_FILE before run."
	echo "Usage: ./PatchCreation.sh newVersionCode [--dev] [--manual-git-diff]"
	echo "Example: ./PatchCreation.sh 1.15 --dev --manual-git-diff"
	exit
fi

# Process the arguments
ENV=""
MANUAL_GIT_DIFF=false
for arg in "$@"; do
	if [ $arg == "--dev" ]; then
		ENV="dev"
	elif [ $arg == "--manual-git-diff" ]; then
		MANUAL_GIT_DIFF=true
	fi
done

if [ $ENV == "dev" ]; then
	echo "Create patch against dev."
else
	echo "Create patch against prod."
fi
if [ $MANUAL_GIT_DIFF == true ]; then
	echo "Use manual git diff file."
fi


# Clear history
if [ $MANUAL_GIT_DIFF == false ]; then
	rm -rf "$WORKING_PATH"
	mkdir "$WORKING_PATH"
fi

function diffVersionWithTags()
{
    if [ $1 == $2 ]; then
        return
    fi

	echo "Create patch from $1 to $2"
	patchDir=$WORKING_PATH/$1_$2
	mkdir "$patchDir"
	if [ $MANUAL_GIT_DIFF == false ]; then
		git diff --name-status $1..$2 > "$patchDir/gitDiff"
	fi

	# If code is changed, no self-update is support for this.
	codeUpdated=false

	while read -r diffInfo
	do
	    diffInfoArr=(${diffInfo//	/ })
	    status="${diffInfoArr[0]}"
	    filePath="${diffInfoArr[1]}"

	    if [ $status = "A" ] || [ $status = "M" ]; then
			if [[ $filePath == *.cpp ]] || [[ $filePath == *.h ]] || [[ $filePath == *.java ]] || [[ $filePath == *.mm ]] || [[ $filePath == *.m ]]; then
	    		# Check code updates
	    		
	    		codeUpdated=true
	    		break
	    	elif [[ $filePath == projects/FootballHero/Resources/CryptLuascripts/* ]]; then
	    		# Ignore some files.
	    		continue
	    	elif [[ $filePath == projects/FootballHero/Resources/game.bin ]] || [[ $filePath == projects/FootballHero/Resources/server ]]; then
	    		# Ignore some files.
	    		continue
	    	elif [[ $filePath == projects/FootballHero/Resources/* ]] || [[ $filePath == projects/FootballHero/Resources/scripts/* ]]; then
	    		# Put in resource files.
	    		shortFilePath=${filePath#projects/FootballHero/Resources/}
	    		newDir=$(dirname $patchDir/$shortFilePath)
		    	mkdir -p $newDir
		    	cp -R $SOURCE_PATH/$filePath $patchDir/$shortFilePath
	    	fi
	    fi
	done < "$patchDir/gitDiff"

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
			echo "$1_needUpdate = true" >> $WORKING_PATH/$PATCH_CONFIG_FILE
			echo "$1_updateTo = $2" >> $WORKING_PATH/$PATCH_CONFIG_FILE
			echo "$1_package = http://portalvhdss3c1vgx5mrzv.blob.core.windows.net/autoupdates$ENV/$1_$2.zip" >> $WORKING_PATH/$PATCH_CONFIG_FILE
			echo "$1_size = $fileSize" >> $WORKING_PATH/$PATCH_CONFIG_FILE
		fi
	fi

	echo "" >> $WORKING_PATH/$PATCH_CONFIG_FILE
}

while read -r v
do
    diffVersionWithTags $v $1
done < $VERSION_FILE

echo "$1.needUpdate = false" >> $WORKING_PATH/$PATCH_CONFIG_FILE