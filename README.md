Convert a cryptographic hash into a string of words by looking them up in a dictionary.  The "key" word is treated
specially and this takes advantage of the BASH features of the RANDOM variable to spread the words across the
dictionary.  Although this has been built and tested with the american-english dictionary, other languages should be
possible.

This is an exercise in the legibility of hexadecimal strings which are not particularly memorable if you are looking at
hexadecimal checksum strings.  This script makes it easy to identify the string with words rather than digits.  It also
includes the inversion that will convert the words back into a hexadecimal number.

I chose the name "gibbons.sh" and "rgibbons.sh" because the sample dataset I used was the freely available text of
Gibbons, "The History of the Decline and Fall of the Roman Empire, Volume 1." which is found at Gutenberg.org.

