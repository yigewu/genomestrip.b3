#!/bin/bash

## SVDiscovery targeting deletion spanning 100 bp - 1M bp

## group names, t for tumor/normal, c for cancer type
t=$1
c=$2

## the path to master directory containing genomestrip scripts, input dependencies and output directories
mainRunDir=$3

#mergeoption="UNIQUIFY"
mergeoption="UNSORTED"

# input BAM
inputDir=${mainRunDir}"inputs/"
batchbamMapFile=$4
## input dependencies
genderMap=$5

## the dir name inside the input directory
refDir="Homo_sapiens_assembly19/"
refFile=${refDir}"Homo_sapiens_assembly19.fasta"

# output directory
batchName=$6
wgs_table="CPTAC3."${batchName}".BamMap.dat"
runDir=${mainRunDir}"outputs/"${batchName}"/"${t}"_"${c}"/"
outDir=${runDir}"vcfsbysample/"
inVCF=${outDir}"del_cnv_genotype_"${t}"_"${c}"_"${mergeoption}".vcf"
mx="-Xmx6g"

# For SVAltAlign, you must use the version of bwa compatible with Genome STRiP.
export SV_DIR=/opt/svtoolkit
export PATH=${SV_DIR}/bwa:${PATH}
export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

mkdir -p ${outDir} || exit 1

cp $0 ${outDir}/


# Run genotyping on the discovered sites.
while read p; do
	sampID=$(echo ${p} | awk -F ' ' '{print $1}')
	echo ${sampID}
	partID=$(grep ${sampID} ${inputDir}${wgs_table} | awk -F ' ' '{print $2}' | uniq)
	echo ${partID}
	if [ "${t}" == "tumor" ]; then
		outVCF=${partID}".T.WGS.CNV.GenomeSTRiP.vcf"
	fi
	if [ "${t}" == "normal" ]; then
		outVCF=${partID}".N.WGS.CNV.GenomeSTRiP.vcf"
	fi
	java -jar ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
		-T SelectVariants \
		-R ${inputDir}${refFile} \
		-V ${inVCF} \
		-o ${outDir}${outVCF} \
		-sn ${sampID} \
		|| exit 1
done<${inputDir}${genderMap}

