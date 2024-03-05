## How to get estimated number of sequenced bases from the different potential output files
## old & new MinKNOW version:

# From the troughtput file haven the following syntax: throughput_<FC>_<run>.csv
awk -F ',' -v col='Estimated Bases' 'NR==1{for(i=1;i<=NF;i++){if($i==col){c=i;break}} print $c} NR>1{print $c}' throughput_<FC>_<run>.csv | tail -n1

