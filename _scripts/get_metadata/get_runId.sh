## Extract the runID and flowcell ID from the final summary
## old & new minKNOW version:

# run ID fom the final summry file
cat final_summary_<FCid>_<run>_<run>.txt | grep 'acquisition_run_id' | sed 's/^.*=//'

# flowcell ID fom the final summry file
cat final_summary_<FCid>_<run>_<run>.txt | grep 'flow_cell_id' | sed 's/^.*=//'
