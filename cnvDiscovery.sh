#!/bin/bash

## SVDiscovery targeting deletion spanning 100 bp - 1M bp

## group names, t for tumor/normal, c for cancer type
t=$1
c=$2

## the path to master directory containing genomestrip scripts, input dependencies and output directories
gsDir=$3

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
outDir=${runDir}"/cnvDiscovery"
mx="-Xmx5g"

# tempory dir
SV_TMPDIR=${runDir}/tmpdir

# For SVAltAlign, you must use the version of bwa compatible with Genome STRiP.
export PATH=${SV_DIR}/bwa:${PATH}
export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

classpath="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"

mkdir -p ${outDir} || exit 1

cp $0 ${outDir}/

# Run discovery.
java -cp ${classpath} ${mx} \
    org.broadinstitute.gatk.queue.QCommandLine \
    -S ${SV_DIR}/qscript/discovery/cnv/CNVDiscoveryPipeline.q \
    -S ${SV_DIR}/qscript/SVQScript.q \
    -cp ${classpath} \
    -gatk ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
    --disableJobReport \
    -jobRunner ParallelShell \
    -gatkJobRunner ParallelShell \
    --maximumNumberOfJobsToRunConcurrently 2 \
    -resMemLimit 5 \
    -configFile ${SV_DIR}/conf/genstrip_parameters.txt \
    -tempDir ${SV_TMPDIR} \
    -R ${inputDir}/${refFile} \
    -I ${inputFile} \
    -genderMapFile ${genderMap} \
    -runDirectory ${outDir} \
    -md ${runDir}/metadata \
    -jobLogDir ${runDir}/logs \
    -intervalList ${inputDir}/${refDir}/Homo_sapiens_assembly19.interval.list \
    -tilingWindowSize 2000 \
    -tilingWindowOverlap 1000 \
    -maximumReferenceGapLength 2000 \
    -boundaryPrecision 100 \
    -minimumRefinedLength 1000 \
    -P select.validateReadPairs:false \
    -run \
    || exit 1
