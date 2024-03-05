## How to get estimated number of sequenced bases from the different potential output files

## throughput_<FC>_<run>.csv
tail -n1 throughput_FAR96408_8097d79f.csv | cut -d ',' -f8

