#!/usr/bin/env bash

conda activate beast

cd /scratch_vol0/fungi/BEAST_vertebrae/04_plants

#beast -threads 4 Murat_parameters.xml
beast -beagle Murat_parameters.xml
