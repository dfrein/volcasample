#!/bin/bash

## Daniel Frein, 2023-01-02
## based on <https://github.com/korginc/volcasample/>
## requires MAX_SYRO_DATA to be increased to 100 (or 200 for volca sample2)
##
## This tool creates WAV files on the basis of vosyr projects for sending them to a korg sample device.
## The program should be executed in a vosyr project directory (e.g. with ./samples/ and ./sequences/ available)
## After executing, three WAV files will be created:
##    erase_all.wav: will clear the complete sample memory (for samples 0-99)
##    samples_all.wav: contains all samples found in ./samples/ in the correct order provided by ./samples/samples
##    sequences_all.wav: contains all 10 patterns from ./sequences/
## These WAV files can then be transferred to the device, e.h. via "aplay"
##
## A (patched) version of "syro_volcasample_example" is required somewhere in $PATH.
## Tested on Ubuntu 2022.10

test -e samples/samples || (echo "ERROR: file './samples/sample' not found"; exit)
test -d sequences/ || (echo "ERROR: directory './sequences' not found"; exit)

## delete all samples, requires patched version (otherwise will only work for up to 10 arguments -- 
## due to "#define	MAX_SYRO_DATA	10" (which can be replaced with 100 or 200)  
echo "INFO: create 'erase_all.wav', if not already existing:"
test -e erase_all.wav || syro_volcasample_example erase_all.wav `seq -s " " -f "e%g:" 0 99`

## generate list of all samples in correct order
SEQ=0
SAMPLES=
for i in `strings samples/samples|grep sample`; do
   SAMPLES="$SAMPLES s${SEQ}c:samples/$i"
   SEQ=$((SEQ + 1))
done

## now create WAV for all samples found:
syro_volcasample_example samples_all.wav $SAMPLES && echo "INFO: created './samples_all.wav'"

## create WAV for all patterns:
SEQUENCES=
for i in {01..10};do 
    SEQUENCES="$SEQUENCES p$i:sequences/sequence$i"
done

syro_volcasample_example sequences_all.wav $SEQUENCES

echo "INFO: created './sequences_all.wav'"
echo "INFO: Now clear volca sample memory and transfer project:"
echo "   aplay erase_all_samples.wav"
echo "   aplay all_samples.wav"
echo "   aplay all_sequences.wav"
