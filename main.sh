#!/bin/bash

## Usage: run genomestrip on CPTAC3 WGS BAMs

## name of the master running directory
toolDirName="genomestrip"

## type of the BAM to be processed
bamType="WGS"

## name of the output directory for different batches
batchName="b2"

## the path to master directory containing "${toolDirName}" scripts, input dependencies and output directories
mainRunDir="/diskmnt/Projects/CPTAC3CNV/"${toolDirName}"/"
mainScriptDir=${mainRunDir}${toolDirName}"/"

## the path to the file containing BAM paths, patient ids, sample ids
bamMapDir="/diskmnt/Projects/cptac/GDC_import/import.config/CPTAC3.b2/"

## the name of the file containing BAM paths, patient ids, sample ids
#bamMapFile="CPTAC3.b1.BamMap.dat"
bamMapFile="CPTAC3.b2.BamMap.dat"

## the master directory holding the BAMs to be processed
bamDir="/diskmnt/Projects/cptac/GDC_import"

## the name of the docker image
imageName="skashin/genome-strip"

## the path to the reference metadata bundle
refDir=" /diskmnt/Projects/Users/mwyczalk/data/docker/data/A_Reference/"
refFile="Homo_sapiens_assembly19.fasta"

## path to the file with gender info for patients
clinicalDir="/diskmnt/Projects/cptac/GDC_import/import.config/CPTAC3.b2/"
clinicalFile="CPTAC3.b2.Demographics.dat"
## tag for log file
id=$1

## make directories

## download dependencies
#bash get_dependencies.sh ${mainRunDir} ${bamMapDir} ${bamMapFile} ${clinicalDir} ${clinicalFile}
#wait

## split BAM path file into batchs
#bash split_bam_path.sh ${mainRunDir} ${bamMapFile} ${bamType}
#wait

## generate gender map file
#bash gender_map.sh ${mainRunDir} ${bamMapFile} ${bamType} ${clinicalFile}
#wait

## run SVPreprocess pipeline
#for t in tumor normal; do
#	for c in CCRC UCEC; do
#		bash run_tmux.sh ${mainRunDir} ${bamMapFile} ${bamType} ${bamDir} ${imageName} "/bin/bash" ${mainScriptDir} "preprocess.sh" ${t} ${c} ${batchName} ${id}
#	done
#done
#exit 1

## wait until the last step is done
## run SVDiscovery pipeline
#for t in tumor normal; do
#        for c in CCRC UCEC; do
#                bash run_tmux.sh ${mainRunDir} ${bamMapFile} ${bamType} ${bamDir} ${imageName} "/bin/bash" ${mainScriptDir} "svDiscovery.sh" ${t} ${c} ${batchName} ${id}
#        done
#done
#exit 1

## wait until the last step is done
## run SVGenotype pipeline
#for t in tumor normal; do
#        for c in CCRC UCEC; do
#                bash run_tmux.sh ${mainRunDir} ${bamMapFile} ${bamType} ${bamDir} ${imageName} "/bin/bash" ${mainScriptDir} "delGenotype.sh" ${t} ${c} ${batchName} ${id}
#        done
#done

## wait until the last step is done
## run CNVDiscovery pipeline
#for t in tumor normal; do
#        for c in CCRC UCEC; do
#                bash run_tmux.sh ${mainRunDir} ${bamMapFile} ${bamType} ${bamDir} ${imageName} "/bin/bash" ${mainScriptDir} "cnvDiscovery.sh" ${t} ${c} ${batchName} ${id} 
#        done
#done
#exit 1

## wait until the last step is done
#for t in tumor normal; do
#        for c in CCRC UCEC; do
#                bash run_tmux.sh ${mainRunDir} ${bamMapFile} ${bamType} ${bamDir} ${imageName} "/bin/bash" ${mainScriptDir} "cnvGenotype.sh" ${t} ${c} ${batchName} ${id} 
#        done
#done
#exit 1



## wait until the last step is done
## run GATK CombineVariants
#for t in tumor normal; do
#        for c in CCRC UCEC; do
#                bash run_tmux.sh ${mainRunDir} ${bamMapFile} ${bamType} ${bamDir} ${imageName} "/bin/bash" ${mainScriptDir} "combine_vcfs.sh" ${t} ${c} ${batchName} ${id}
#        done
#done
#exit 1

## wait until the last step is done
## run GATK SelectVariants
for t in tumor normal; do
        for c in CCRC UCEC; do
               bash run_tmux.sh ${mainRunDir} ${bamMapFile} ${bamType} ${bamDir} ${imageName} "/bin/bash" ${mainScriptDir} "split_vcfs_by_sample.sh" ${t} ${c} ${batchName} ${id}
        done
done
exit 1
