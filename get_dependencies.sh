#!/bin/bash

mainRunDir=$1
inputDir=${mainRunDir}"inputs/"

bamMapDir=$2
bamMapFile=$3
clinicalDir=$4
clinicalFile=$5

## download reference metadata bundle
#cd ${inputDir}
#wget ftp://ftp.broadinstitute.org/pub/svtoolkit/reference_metadata_bundles/Homo_sapiens_assembly19_12May2015.tar.gz
#tar -zxvf Homo_sapiens_assembly19_12May2015.tar.gz

## copy file
cp ${bamMapDir}${bamMapFile} ${inputDir}${bamMapFile}
cp ${clinicalDir}${clinicalFile} ${inputDir}${clinicalFile}
