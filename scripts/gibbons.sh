#!/bin/bash
scriptname=${0##*/}
####################
# Copyright (c) 2021 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# gibbons - Turn the hash code for Gibbons into a string of words.
#           Optionally you can specify the dictionary found on 
#           Linux systems, the dictionary locations may vary by
#           distribution
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
\t\tan idiosyncrasy of the Linux American English dictionary is\r\n
\t\tthat it explicityly lists the possessive forms of words.\r\n
\t\tThis application first strips out all of the possessive\r\n
\t\tof the words to avoid this idiosyncratic form of the\r\n
\t\tdictionary.\r\n
\t-d\t<#>\tis the number which designates the level of diagnostic\r\n
\t\t\toutput that is generated:
\t\t\tDEBUGWAVE\t2\tIf the entry/exit macros are used prints a wave\r\n
\t\t\t\t\t\tlike trace of entry/exit to functions (currently\r\n
\t\t\t\t\t\tnot implemented).\r\n
\t\t\tDEBUGVAR\t3\tPrint variable data from functions if enabled\r\n
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
FUNC_DEBUG=${DEBUGOFFF}
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
echo "bits16=${bits16}"
echo "wcount=${wcount}"
echo "modulo=${modulo}"
if [ "${modulo}" -gt "${bits16}" ]
then
  errecho ${FUNCNAME} ${LINENO} \
    "Chosen dictionary and options break assumptions for this application"
  errecho ${FUNCNAME} ${LINENO} \
    "Choose a different combination or modify the script."
  errecho ${USAGE}
  exit -1
fi

######################################################################
# In this program we are using Blake2 (which is VERY fast in software)
# sha256 (or shasum) would also be a good candidate,  It us left as
# an exercise for a maintainer to ass parameter selection for 
# alternate cryptographic hash checksums
######################################################################
hashexec=b2sum
hashhexbytes=128
genhash=$(${hashexec} ${INFILE})
bhash=${genhash:0:${hashhexbytes}}
echo $bhash
wordindex=0
declare -a words
while read -r input
do
  words[${wordindex}]=${input}
  wordindex=$((wordindex+1))
done < ${NOPOSS}

######################################################################
# Hard coded assumption here that the dictionary size is less then 
# 2* 2^16 and that we will use 16 bit values encoded as hex strings
# which are 4 characters long.
######################################################################
# output the index used to create the first seed for Random
# I chose to use this obscure BASH built-in rather then invoking 'bc'
# to convert from hex to decimal to avoid an external process.
######################################################################
char4=4
index=s
first16=${bhash:${index}:${char4}}
wordindex=$((16#${first16}))
RANDOM=${wordindex}
echo -n "${words[${wordindex}]}-"

DIAG=/tmp/diag$$.txt
rm -f ${DIAG}
echo -e "first16\twordindex\tnewindex" >> ${DIAG}

index=s
while [ "${index}" -lt "${chars}" ]
do
  first16=${bhash:${index}:${char4}}
  wordindex=$((16#${first16}))
  newindex=$(((RANDOM%modulo)+wordindex))
  echo -e "${first16}\t${wordindex}\t${newindex}" >> ${DIAG}
  if [ "$index" -ne 0 ]
  then
    echo -n "-"
  fi
  echo -n ${words[${newindex}]}
  index=$((index+char4))
done

echo ""
# rm -f ${DIAG}
more ${DIAG}
