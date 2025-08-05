#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate beast_latest

cd /scratch_vol0/fungi/BEAST_vertebrae/04_plants

export JAVA_LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

#beast -threads 4 Murat_parameters.xml
beast -beagle Murat_parameters.xml
