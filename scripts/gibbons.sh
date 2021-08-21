#!/bin/bash
scriptname=${0##*/}
####################
# Copyright (c) 2021 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# gibbons - Turn the hash code for Gibbons into a string of words.
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
# 1.0 | REN |08/21/2021| Initial Release
#_____________________________________________________________________
#
######################################################################
######################################################################

DICTIONARY=/usr/share/dict/american-english
NOPOSS=/tmp/no-possessive
wcount=$(cat ${NOPOSS} | wc -l)
modulo=$((wcount-65536))
dictprep ${DICTIONARY} ${NOPOSS}
GIBBONSv1=${HOME}/Dropbox/AAA_My_Jobs/oth/Gutenberg/890/890-0.txt
if [ ! -r ${GIBBONSv1} ]
then
  errecho ${FUNCNAME} {LINENO} \
    "GIBBONSv1 not found \"${GIBBONSv1}\""
  exit -1
fi
bhash=$(getb2sum ${GIBBONSv1})
chars=${#bhash}
firstindex=${bhash:0:4}
# echo ${firstindex}
RANDOM=$((16#${firstindex}))
wordindex=0
declare -a words
while read -r input
do
  words[${wordindex}]=${input}
  wordindex=$((wordindex+1))
done < ${NOPOSS}
index=0
while [ "${index}" -lt "${chars}" ]
do
  first16=${bhash:${index}:4}
  wordindex=$((16#${first16}))
#  echo "wordindex=${wordindex}"
  newindex=$((RANDOM%modulo))
#   echo $wordindex
#  echo "newindex=${newindex}"
  if [ "$index" -ne 0 ]
  then
    echo -n "-"
  fi
  echo -n ${words[${newindex}]}
  index=$((index+4))
done

echo ""
