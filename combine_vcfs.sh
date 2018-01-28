#!/bin/bash

## SVDiscovery targeting deletion spanning 100 bp - 1M bp

## group names, t for tumor/normal, c for cancer type
t=$1
c=$2

## the path to master directory containing genomestrip scripts, input dependencies and output directories
gsDir=$3

#mergeoption="UNIQUIFY"
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
mx="-Xmx6g"

# input discovery vcf
delVCF=${runDir}"/delGenotype/del_genotype_"${t}"_"${c}".vcf"
cnvVCF=${runDir}"/cnvDiscovery/results/gs_cnv.genotypes.vcf"

# unzip the vcf if necessary
if [ ! -e ${cnvVCF} -a -e ${cnvVCF}.gz ]; then
    gunzip ${cnvVCF}.gz
fi

# tempory dir
SV_TMPDIR=${runDir}/tmpdir

# For SVAltAlign, you must use the version of bwa compatible with Genome STRiP.
export PATH=${SV_DIR}/bwa:${PATH}
export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

classpath="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"

mkdir -p ${outDir} || exit 1

cp $0 ${outDir}/

# Run genotyping on the discovered sites.
java -jar ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
	-T CombineVariants \
	-R ${inputDir}/${refFile} \
	--variant ${delVCF} \
	--variant ${cnvVCF} \
	-o ${outDir}"/"${t}"_"${c}"_del_cnv_"${mergeoption}"_combined.vcf" \
	--genotypemergeoption ${mergeoption} \
	|| exit 1
