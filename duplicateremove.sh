#!/bin/bash
#
# This shell script deletes duplicate files through either string or hash comparison.
#
# Stephen Turner
#
# *************************************************************************************************
# Functions
function funcA1 {
  # Find all files in the current directory - awk the file name tolower minus the first line
  find . -maxdepth 1 -type f -exec ls -lSAo {} \; | awk '{print tolower($8)}' | \
  while read line; do
      # If the file exist within the array then delete the duplicate file
      if (echo ${arrFiles[@]} | grep -wq $line); then
      rm -f $line
    # The file does not exist in the array, add it to arrFiles
    else
      arrFiles[intFcount]=$line
      echo $line
   fi
  let "intFcount+=1"
  done  
}

readonly -f funcA1        		# Function readonly
declare -t funcA1			# Function - Load users into arrUsers

function funcA2 {
  find . -maxdepth 1 -type f -exec ls -lSAo {} \; | awk -F "./" '{print $2}' | \
  while read line; do
   strMd5sum=$(md5sum "$line" | awk '{print $1}')
   # If the file MD5 hash exist within the array then delete the duplicate file
   if (echo ${arrFiles[@]} | grep -wq $strMd5sum); then
      rm -f "$line"
   # The file md5 does not exist in the array, add it to arrFiles
   else
      arrFiles[intFcount]=$strMd5sum
      echo "MD5:$strMd5sum  - $line"
   fi
  let "intFcount+=1"
done  
}

readonly -f funcA2        		# Function readonly
declare -t funcA2			# Function - Load users into arrUsers

# *************************************************************************************************
# Variable Declaration

declare -rx find="/usr/bin/find"	# Last pointer
declare strScriptTitle=${0##*/}		# String - The script file name
declare -i intFcount=0			# Integer - Counter variable for file count
declare -a arrFiles			# Array - Container for valid files

#
# *************************************************************************************************
# Sanity Checks

if test ! -x "$find" ; then
	printf "$strScriptTitle:$LINENO: the find command failed... aborting" >&2
	exit 192
fi

# *************************************************************************************************
# Main

echo "Answer 1 - Remove all duplicates via name match"
echo "Answer 2 - Remove all duplicates via Md5 match"
printf "1 = Answer 1, 2 = Answer 2: "
read strREPLY
  case "$strREPLY" in
  1) funcA1 ;;
  2) funcA2 ;;
  *) printf "%s\n" "Please 1 or 2" ;;
esac

# *************************************************************************************************
# Clean up
exit 0

