#!/bin/bash

for f in /data-fast/twitter\ 2020/*.zip; do
	nohup ./src/map.py --input_path=/$f &
done
