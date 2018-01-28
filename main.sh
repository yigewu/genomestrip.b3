#!/bin/bash

## make directories

## download dependencies
bash download_dependencies.sh
wait

## split BAM path file into batchs
bash split_input_paths.sh
wait

## generate gender map file
bash gender_map.sh
wait

## run SVPreprocess pipeline
for t in tumor normal; do
	for c in CCRC UCEC; do
		bash run_tmux.sh ${t} ${c} preprocess.sh
	done
done
exit 1

## wait until the last step is done
## run SVDiscovery pipeline
for t in tumor normal; do
        for c in CCRC UCEC; do
                bash run_tmux.sh ${t} ${c} svDiscovery.sh
        done
done
exit 1

## wait until the last step is done
## run SVGenotype pipeline
for t in tumor normal; do
        for c in CCRC UCEC; do
                bash run_tmux.sh ${t} ${c} delGenotype.sh
        done
done
exit 1

## wait until the last step is done
## run CNVDiscovery pipeline
for t in tumor normal; do
        for c in CCRC UCEC; do
                bash run_tmux.sh ${t} ${c} cnvDiscovery.sh
        done
done
exit 1

## wait until the last step is done
## run GATK CombineVariants
for t in tumor normal; do
        for c in CCRC UCEC; do
                bash run_tmux.sh ${t} ${c} combine_vcfs.sh
        done
done
exit 1

## wait until the last step is done
## run GATK SelectVariants
for t in tumor normal; do
        for c in CCRC UCEC; do
                bash run_tmux.sh ${t} ${c} split_vcfs_by_sample.sh
        done
done
exit 1
