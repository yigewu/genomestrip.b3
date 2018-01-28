#!/bin/bash

bamMap="/diskmnt/Projects/cptac/genomestrip/inputs/CPTAC3.b1.WGS.BamMap.dat"

for i in tumor normal; do
    for j in CCRC UCEC; do
        grep ${i} ${bamMap} | grep ${j} |  awk -F '\\s' '{print $6}' | awk -F 'import' '{print $1"import/data"$2}' > ${bamMap}"_"${i}"_"${j}".list" 
    done
done

