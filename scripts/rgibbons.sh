#!/bin/bash
scriptname=${0##*/}
####################
# Copyright (c) 2021 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# rgibbons - Turn the string of words back into a hash code
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
source func.errecho

DICTIONARY=/usr/share/dict/american-english
NOPOSS=/tmp/no-possessive
wcount=$(cat ${NOPOSS} | wc -l)
modulo=$((wcount-65536))
dictprep ${DICTIONARY} ${NOPOSS}
if [ $# -gt 0 ]
then
  codedhash="$1"
fi
if [ ! -r ${codedhash} ]
then
  errecho ${FUNCNAME} {LINENO} \
    "codedhash not found \"${codedhash}\""
  exit -1
fi
exphash=/tmp/exphash$$
enchash=/tmp/enchash$$
DIAG=/tmp/diag.txt
tr '-' '\n' < ${codedhash} > ${exphash}
tail +2 ${exphash} > ${enchash}
wordseed=$(head -1 ${exphash})
cat ${exphash} >> ${DIAG}
echo "wordseed=${wordseed}" >> ${DIAG}
# randomseed=$(awk "NR==${firstindex}" < ${NOPOSS})
# echo ${firstindex}
# RANDOM=$((16#${firstindex}))
wordindex=0
declare -a words
declare -A hashes
while read -r input
do
  words[${wordindex}]=${input}
  hashes+=([${input}]=${wordindex})
  wordindex=$((wordindex+1))
done < ${NOPOSS}
randomseed=${hashes[${wordseed}]}
RANDOM=${randomseed}
index=0
while read -r input
do
  echo -n -e  $input}\t >> ${DIAG}
  wordindex=${hashes[${input}]}
  echo -n -e ${wordindex}a\t >> ${DIAG}
  wordindex=$((wordindex-(RANDOM%modulo)))
  echo -n -e ${wordindex}a\t >> ${DIAG}
  echo -n "$(printf '%4x' ${wordindex})" | tee -a ${DIAG}
  echo "" >> ${DIAG}
done < ${enchash}
rm -f ${enchash} ${exphash}
echo ""
cat ${DIAG}
