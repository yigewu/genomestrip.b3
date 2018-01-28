#!/bin/bash

## group names, t for tumor/normal, c for cancer type
t=$1
c=$2

# input BAM
inputDir=/diskmnt/Projects/cptac/genomestrip/inputs
inputFile="/diskmnt/Projects/cptac/genomestrip/inputs/CPTAC3.b1.WGS.BamMap.dat_"${t}"_"${c}".list"
inputType=bam

# input dependencies
export SV_DIR=/opt/svtoolkit
genderMap=${inputDir}"/gender_map_"${t}"_"${c}
## the dir name inside the input directory
refDir=Homo_sapiens_assembly19
refFile=${refDir}/Homo_sapiens_assembly19.fasta

# output
runDir=/diskmnt/Projects/cptac/genomestrip/outputs/${t}"_"${c}
mx="-Xmx6g"

# tempory dir
SV_TMPDIR=${runDir}/tmpdir

# These executables must be on your path.
which java > /dev/null || exit 1
which Rscript > /dev/null || exit 1
which samtools > /dev/null || exit 1

# For SVAltAlign, you must use the version of bwa compatible with Genome STRiP.
export PATH=${SV_DIR}/bwa:${PATH}
export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

classpath="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"

mkdir -p ${runDir}/logs || exit 1
mkdir -p ${runDir}/metadata || exit 1

cp /diskmnt/Projects/cptac/genomestrip/genomestrip/preprocess.sh ${runDir}/

# Unzip the reference sequence and masks if necessary
if [ ! -e ${inputDir}/${refFile} -a -e ${inputDir}/${refFile}.gz ]; then
    gunzip ${inputDir}/${refFile}.gz
fi
if [ ! -e ${inputDir}/${genomeMaskFile} -a -e ${inputDir}/${genomeMaskFile}.gz ]; then
    gunzip ${inputDir}/${genomeMaskFile}.gz
fi
if [ ! -e ${inputDir}/${copyNumberMaskFile} -a -e ${inputDir}/${copyNumberMaskFile}.gz ]; then
    gunzip ${inputDir}/${copyNumberMaskFile}.gz
fi

# Display version information.
java -cp ${classpath} ${mx} -jar ${SV_DIR}/lib/SVToolkit.jar

# Run preprocessing.
# For large scale use, you should use -reduceInsertSizeDistributions, but this is too slow for the installation test.
# The method employed by -computeGCProfiles requires a GC mask and is currently only supported for human genomes.
java -cp ${classpath} ${mx} \
    org.broadinstitute.gatk.queue.QCommandLine \
    -S ${SV_DIR}/qscript/SVPreprocess.q \
    -S ${SV_DIR}/qscript/SVQScript.q \
    -gatk ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
    --disableJobReport \
    -jobRunner ParallelShell \
    -cp ${classpath} \
    -configFile ${SV_DIR}/conf/genstrip_parameters.txt \
    -tempDir ${SV_TMPDIR} \
    -R ${inputDir}/${refFile} \
    -genderMapFile ${genderMap} \
    -runDirectory ${runDir} \
    -md ${runDir}/metadata \
    -jobLogDir ${runDir}/logs \
    -I ${inputFile} \
    -run \
    || exit 1

