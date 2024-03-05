## Extract the number of active pores at run start

## old minKNOW version -- mux_scan_data_<fc_id>_<run_id>.csv
head -n 2049 mux_scan_data_<fc_id>_<run_id>.csv | awk -F ',' -v col='mux_scan_assessment' 'NR==1{for(i=1;i<=NF;i++){if($i==col){c=i;break}} print $c} NR>1{print $c}' | grep 'single_pore\|other' | wc -l
# alternatively
awk -F , '{if ($35==1 && $27==1){print $0}}' mux_scan_data_<fc_id>_<run_id>.csv | wc -l

## new minKNOW version
head -n 2049 pore_scan_data_<fc_id>_<run_id>_<run_id>.csv | awk -F ',' -v col='mux_scan_assessment' 'NR==1{for(i=1;i<=NF;i++){if($i==col){c=i;break}} print $c} NR>1{print $c}' | grep 'single_pore\|other' | wc -l
