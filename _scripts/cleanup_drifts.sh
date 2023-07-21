#!/bin/bash

#####################################################################
# Script to remove unneccessary columns from drift correction files #
#####################################################################

# first, generate folder for all cleaned files
mkdir ../_data/_clean_drifts/

# loop through all drift_correction*
for i in $(ls ../_data/drift_*)
    do
    # run Rscript named "cleanup_drifts.R"
    Rscript cleanup_drifts.R $i
done

# add first 8 run_id digits as new column
for j in $(ls ../_data/*_cleaned)
    do
    a=$(ls $j | cut -d_ -f5 | cut -d. -f1)
    cat $j | sed "s/$/,$a/" > "${j}_digits"
done

# put all clean drift files in _clean_drifts folder
mv ../_data/*_digits ../_data/_clean_drifts/
rm ../_data/*_cleaned

# concatenate all cleaned files into a single file
cat ../_data/_clean_drifts/*_digits >> ../_data/all_cleaned_drifts.csv
# remove single *_cleaned files
rm -r ../_data/_clean_drifts/