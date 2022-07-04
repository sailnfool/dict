#!/bin/bash
scriptname=${0##*/}
####################
# Copyright (c) 2021 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# dictprep - Remove the possessives from the specified dictionary
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|08/21/2021| Initial Release
#_____________________________________________________________________
#
######################################################################
######################################################################

source func.insufficient
source func.errecho

# DICTIONARY=/usr/share/dict/american-english
# NOPOSS=/tmp/no-possessive
if [ $# -ne 2 ]
then
  insufficient 2 $@
  exit -1
fi
DICTIONARY="$1"
NOPOSS="$2"
if [ ! -r ${DICTIONARY} ]
then
  errecho ${FUNCNAME} {LINENO} \
    "Dictionary not found \"${DICTIONARY}\""
  exit -1
fi
sed -e "/'s$/d" < ${DICTIONARY} > ${NOPOSS}
