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
# This needs all of the same USAGE and options as gibbons
######################################################################
source func.debug
source func.errecho
source func.insufficient

USAGE="\r\n${scriptname} [-hp]  [-d <dictionary>] <text file>\r\n
\t\tReads a <text file> and computes a Blake2 cryptographics hash\r\n
\t\tfor the text file and then encodes the 256 bit hash into a\r\n
\t\tstring of dictionary words.  The first word output is used\r\n
\t\tas the seed to the BASH random number generator.  The seed\r\n
\t\tis chosen as the first 16 bits <0-65535> of the generated \r\n
\t\tthe use of the random function is to spread the words over\r\n
\t\tthe dictionary.  E.G. if the dictionary has 73,568 words\r\n
\t\teach 16 bits of the hash are used as the base index into the\r\n
\t\tdictionary.  To that we add a random number between <0-8032>\r\n
\t\tto insure that we are not modulo 65535 in the selection of\r\n
\t\twords for the encoding.  At first glance this might seem to\r\n
\t\tbe simply an obfuscation of the data already condtained in\r\n
\t\tthe 256-bit number which is the hash.  It is intended as a\r\n
\t\thuman readable diagnostic tool for applications that generate\r\n
\t\tlong (normally ASCII HEX encoded) strings into mnemonic names\r\n
\t\tthat diagnostic engineers can use to mnemonically remember\r\n
\t\tthese strings which would be opaque otherwise.\r\n
\r\n
\t\tAn idiosyncrasy of the Linux American English dictionary is\r\n
\t\tthat it explicitly lists the possessive forms of words.\r\n
\t\tThis application first strips out all of the possessive\r\n
\t\tof the words to avoid this idiosyncratic form of the\r\n
\t\tdictionary.\r\n
\t-d\t<#>\tis the number which designates the level of diagnostic\r\n
\t\t\toutput that is generated:\r\n
\t\t\tDEBUGWAVE\t2\tIf the entry/exit macros are used prints a wave\r\n
\t\t\t\t\t\tlike trace of entry/exit to functions (currently\r\n
\t\t\t\t\t\tnot implemented).\r\n
\t\t\tDEBUGWAVAR\t3\tPrint variable data from functions if enabled\r\n
\t\t\tDEBUGSTRACE\t5\tPrefix the executable with strace\r\n
\t\t\t\t\t\tif implemented).\r\n
\t\t\tDEBUGNOEXECUTE or\r\n
\t\t\tDEBUGNOEX\t6\tGenerate and display the command lines but\r\n
\t\t\t\t\t\tdon't execute the program.\r\n
\t\t\tDEBUGSETX\t9\tTurn on set -x to trace the BASH execution\r\n
\t-h\t\tPrint this help information.\r\n
\t-p\t\tSuppress the stripping of the possessive forms of words\r\n
\t-t\t<dictionary>\tSpecify an alternate dictionary, default is\r\n
\t\t\t/usr/share/dict/american-english\r\n
\t<text file>\t\tThe default text file is the text version of\r\n
\t\t\tGibbons, \"The Decline and Fall of the Roman Empire, Vol. 1\"\r\n
\t\t\twhich is found at Gutenberg.org\r\n
"
donstrip="FALSE"
DICTIONARY=/usr/share/dict/american-english
optionargs="dhpt:"
NUMARGS=1
FUNC_DEBUG=${DEBUGOFF}
export FUNC_DEBUG

while getopts ${optionargs} name
do
  case ${name} in
  d)
    FUNC_DEBUG="${OPTARG}"
    if [[ ! "${FUNC_DEBUG}" =~ $re_integer ]]
    then
      errecho ${FUNCNAME} ${LINENO} \
        "INVALID '-d' argument, must be an integer '${FUNC_DEBUG}'"
    fi
    ;;
	h)
		errecho "-e" ${USAGE}
		exit 0
		;;
  t)
    DICTIONARY="${OPTARG}"
    ;;
  p)
    dontstrip="TRUE"
    ;;
	\?)
    errecho ${FUNCNAME} ${LINENO} \
		  "invalid option: -${OPTARG}"
		errecho "-e" ${USAGE}
		exit 1
		;;
	esac
done

if [ $# -lt ${NUMARGS} ]
then
	errecho "-e" ${USAGE}
	insufficient ${NUMARGS} $@
	exit -2
fi
shift $((OPTIND -1))

INFILE="$1"

if [ ! -r "${DICTIONARY}" ]
then
  errecho ${FUNCNAME} ${LINENO} \
    "Unable to read DICTIONARY=\"${DICTIONARY}\""
  exit -1
fi
if [ ! -r "${INFILE}" ]
then
  errecho ${FUNCNAME} ${LINENO} \
    "Unable to read INFILE=\"${INFILE}\""
  exit -1
fi


NOPOSS=/tmp/no-possessive
if [ "${dontstrip}" = "TRUE" ]
then
  cp "${DICTIONARY}" "${NOPOSS}"
else
  dictprep ${DICTIONARY} ${NOPOSS}
fi

bits16=$(echo '2^16' | bc)
wcount=$(cat ${NOPOSS} | wc -l)
modulo=$((wcount-bits16))
if [ "${FUNC_DEBUG}" -eq "${DEBUGWAVAR}" ]
then
  echo "bits16=${bits16}"
  echo "wcount=${wcount}"
  echo "modulo=${modulo}"
fi

######################################################################
# We are going to expand the words separated by hyphens to words
# separated by newlines.  The first word of the list is the encoding
# key "wordseed" which will be used for the RANDOM bash seed.
# The rest of the encoded words expressing the hash is "enchash"
######################################################################
exphash=/tmp/exphash$$
enchash=/tmp/enchash$$
tr '-' '\n' < ${INFILE} > ${exphash}
if [ "${FUNC_DEBUG}" -eq "${DEBUGWAVAR}" ]
then
  DIAG=/tmp/diag.txt
  cat ${exphash} >> ${DIAG}
  echo "wordseed=${wordseed}" >> ${DIAG}
fi

######################################################################
# This takes a little explanation.  We read the dictionary and in words
# by the index number we have the words tied to that number.  The 
# hashes array is indexed by the words used in the encodeing and are
# used to look up the numeric values of those words.  There might be
# a more efficient way, but from a code writing effort this is an
# easy way to look up the numeric value of a word.
######################################################################
wordindex=0
declare -a words
declare -A hashes
while read -r input
do
  words[${wordindex}]=${input}
  hashes+=([${input}]=${wordindex})
  wordindex=$((wordindex+1))
done < ${NOPOSS}

tail +2 ${exphash} > ${enchash}
wordseed=$(head -1 ${exphash})
randomseed=${hashes[${wordseed}]}

######################################################################
# seed the BASH RANDOM Number generator so we can repeat and reverse
# the sequence of pseudo-random seeded numbers to recover the numeric
# values of the words.
######################################################################
RANDOM=${randomseed}
index=0
while read -r input
do
  if [ "${FUNC_DEBUG}" -eq "${DEBUGWAVAR}" ]
  then
    echo -n -e  ${input}\t >> ${DIAG}
  fi
  wordindex=${hashes[${input}]}
  if [ "${FUNC_DEBUG}" -eq "${DEBUGWAVAR}" ]
  then
    echo -n -e ${wordindex}a\t >> ${DIAG}
  fi
  wordindex=$((wordindex-(RANDOM%modulo)))
  if [ "${FUNC_DEBUG}" -eq "${DEBUGWAVAR}" ]
  then
    echo -n -e ${wordindex}a\t >> ${DIAG}
    echo -n "$(printf '%4x' ${wordindex})" >> ${DIAG}
  fi
  echo -n "$(printf '%4x' ${wordindex})" 
  if [ "${FUNC_DEBUG}" -eq "${DEBUGWAVAR}" ]
  then
    echo "" >> ${DIAG}
  fi
done < ${enchash}
rm -f ${enchash} ${exphash}
echo ""
if [ "${FUNC_DEBUG}" -eq "${DEBUGWAVAR}" ]
then
  cat ${DIAG}
  rm -f ${DIAG}
fi
