#!/bin/bash

## SVDiscovery targeting deletion spanning 100 bp - 1M bp

## group names, t for tumor/normal, c for cancer type
t=$1
c=$2

## the path to master directory containing genomestrip scripts, input dependencies and output directories
gsDir=$3

## the name of the file containing the gender map
genderFile=$4

wgs_table="CPTAC3.b1.WGS.BamMap.dat"
mergeoption="UNSORTED"


# input BAM
inputDir=${gsDir}"/inputs"
inputFile=${gsDir}"/inputs/CPTAC3.b1.WGS.BamMap.dat_"${t}"_"${c}".list"
inputType=bam

# input dependencies
export SV_DIR=/opt/svtoolkit
genderMap=${inputDir}"/gender_map_"${t}"_"${c}
## the dir name inside the input directory
refDir=Homo_sapiens_assembly19
refFile=${refDir}/Homo_sapiens_assembly19.fasta

# output
runDir=${gsDir}"/outputs/"${t}"_"${c}
outDir=${runDir}"/vcfsbysample"
vcfFile=${outDir}"/"${t}"_"${c}"_del_cnv_"${mergeoption}"_combined.vcf"
mx="-Xmx6g"

# tempory dir
SV_TMPDIR=${runDir}/tmpdir

# For SVAltAlign, you must use the version of bwa compatible with Genome STRiP.
export PATH=${SV_DIR}/bwa:${PATH}
export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

classpath="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"

mkdir -p ${outDir} || exit 1

cp $0 ${outDir}/


# Run genotyping on the discovered sites.
while read p; do
	sampID=$(echo ${p} | awk -F ' ' '{print $1}')
	echo $sampID
	partID=$(grep ${sampID} ${inputDir}"/"${wgs_table} | awk -F '\t' '{print $2}')
	if [ "${t}" == "tumor" ]; then
		outVCF=${partID}".T.vcf"
	fi
        if [ "${t}" == "normal" ]; then
                outVCF=${partID}".N.vcf"
        fi
	java -jar ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
		-T SelectVariants \
		-R ${inputDir}"/"${refFile} \
		-V ${vcfFile} \
		-o ${outDir}"/"${outVCF} \
		-sn ${sampID} \
		|| exit 1
done<${inputDir}"/"${genderFile}

