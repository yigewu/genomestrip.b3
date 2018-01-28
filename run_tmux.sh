#!/bin/bash

## Usage: bash run_tmux.sh {tumor/normal} {CCRC/UCEC} {script_name_to_run} 

## batch identifiers, t for tumor/normal, c for cancer type
t=$1
c=$2

## script name to run
s=$3

## user ID with permission to the input files
uid=$(id -u)

## group ID with permission to the input files
gid="2001"

## the path to master directory containing genomestrip scripts, input dependencies and output directories
#gsDir="/diskmnt/Projects/cptac/genomestrip"
gsDir="/diskmnt/Projects/CPTAC3CNV/genomestrip"

## the path to master directory containing input BAM files
bamDir="/diskmnt/Projects/cptac/GDC_import"

## the name of the file containing the gender map
genderFile="gender_map_"${t}"_"${c}

bashCMD="tmux new-session -d -s genomestrip_"${s}"_"${t}"_"${c}" 'docker run --user "${uid}":"${gid}" -v "${gsDir}":"${gsDir}" -v "${bamDir}":"${bamDir}" skashin/genome-strip /bin/bash "${gsDir}"/genomestrip/"${s}" "${t}" "${c}" "${gsDir}" "${genderFile}" |& tee "${s}"_"${t}"_"${c}".log'" 
echo $bashCMD
$bashCMD
