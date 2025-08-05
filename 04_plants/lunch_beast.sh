#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate beast_latest

cd /scratch_vol0/fungi/BEAST_vertebrae/04_plants

export LD_LIBRARY_PATH=$HOME/lib:$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
export JAVA_OPTS="-Djava.library.path=$HOME/lib"

beast -beagle Murat_parameters.xml
