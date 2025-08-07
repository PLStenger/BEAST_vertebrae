#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate beast_latest

# Masquer les anciennes libs conda BEAGLE
for f in libhmsbeagle.so libhmsbeagle.so.1 libhmsbeagle-jni.so libhmsbeagle-cpu-sse.so libhmsbeagle-cpu.so libhmsbeagle-cpu-sse.so.31.0.0 libhmsbeagle-cpu.so.31.0.0 libhmsbeagle.so.1.3.2; do
  if [ -f "$CONDA_PREFIX/lib/$f" ]; then
    mv "$CONDA_PREFIX/lib/$f" "$CONDA_PREFIX/lib/$f.bak"
  fi
done

export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH
export JAVA_OPTS="-Djava.library.path=$HOME/lib"

#beast -beagle Test_01.xml
cd /scratch_vol0/fungi/BEAST_vertebrae/04_plants/beast/bin

./beast /scratch_vol0/fungi/BEAST_vertebrae/04_plants/Murat_WAG_six_fossils.xml
