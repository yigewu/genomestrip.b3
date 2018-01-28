#!/bin/bash

inputDir="/diskmnt/Projects/cptac/genomestrip/inputs/"
bamMap="/diskmnt/Projects/cptac/genomestrip/inputs/CPTAC3.b1.WGS.BamMap.dat"

## directory of gender info files
genderDir="/diskmnt/Projects/Users/mwyczalk/data/import.CPTAC3/import.CPTAC3.b1/config/"

for i in tumor normal; do
    for j in CCRC UCEC; do
        touch ${inputDir}"gender_map_"${i}"_"${j} > ${inputDir}"gender_map_"${i}"_"${j}
        while IFS= read -r var; do
            samtools view -H ${var} | grep SM | awk -F '\t' '{print $3}' | uniq | awk -F 'SM:' '{print $2}' > tmp/tmp_specimen
            cat tmp/tmp_specimen | grep -f - ${bamMap} | awk -F '\\s' '{print $2}' > tmp/tmp_case 
            cat tmp/tmp_case | grep -f - ${genderDir}${j}"_Demographics.dat" | awk -F '\t' '{print $3}' > tmp/tmp_gender
            if [ "$(cat tmp/tmp_gender)" == "male" ]; then
                cat tmp/tmp_specimen | awk '{print $1"\tM"}' >> ${inputDir}"gender_map_"${i}"_"${j} 
            fi
            if [ "$(cat tmp/tmp_gender)" == "female" ]; then
                cat tmp/tmp_specimen | awk '{print $1"\tF"}' >> ${inputDir}"gender_map_"${i}"_"${j}
            fi
        done < ${bamMap}"_"${i}"_"${j}
    done
done

