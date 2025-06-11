#!/bin/bash

cd /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_raw_data/MultipleSequenceAlignments

while read og; do
    cp "${og}.fa" /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/01_3350_OG/
done < /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_raw_data/ucg.txt
