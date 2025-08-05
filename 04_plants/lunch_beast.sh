#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
#conda activate beast
conda activate beast_latest


cd /scratch_vol0/fungi/BEAST_vertebrae/04_plants

#beast -threads 4 Murat_parameters.xml
beast -beagle Murat_parameters.xml
