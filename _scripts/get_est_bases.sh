#!/bin/bash

#####################################################################
# Script to get the number of estimated bases from report markdowns #
#####################################################################

for i in $(ls ../_data/*.md)
    do
    echo $i
    A=$(tail $i | sed '/^[[:space:]]*$/d' | sed '/^-/d' | cut -d , -f8 | awk 'NR==0; END{print}')
    B=$(cat $i | grep 'sample_id' | sed 's/:/,/' | cut -d , -f 2 | sed 's/"//g' | sed 's/ //g')
    C=$(cat $i | grep '"run_id"' | sed 's/:/,/' | cut -d , -f 2 | sed 's/"//g' | sed 's/ //g')
    echo $A,$B,$C >> ../_data/all_est_bases.csv

done