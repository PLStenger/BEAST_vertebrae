#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate beast

cd /scratch_vol0/fungi/BEAST_vertebrae/04_plants

export JAVA_LIBRARY_PATH=/usr/local/lib

#beast -threads 4 Murat_parameters.xml
beast -beagle Murat_parameters.xml
