# Metaanalysis of >200 nanopore sequencing runs <br /> (Meyer et al., 2023)

### Goal
Over the course of many years we have sequenced RNA and DNA from a large variety of species. When we compared different sequencing runs we have noticed that the performance of Oxford Nanopore Minion flow cells varied drastically across runs. In order systematically analyse which factors do or do not influence the lifetime of a flowcell (and consequently the number of sequenced bases) we analyses several parameters that vary across sequencing runs.

### Input data from the wetlab
- Data related to wetlab (e.g. amount of library loaded on flowcell etc) was manually gathered by the staff in the laboratory. All information can be found at ./_data/wetlab_data_230607.csv.
- TODO: \#cha, \#por, fc age

### Input data from the drylab
- **Flow cell half-life**: The half-life of each flow cell was calculated using the *drift_correction* files which are generated with each sequencing run. We concatenated the drift correction files upon clean up using costum scripts (./_scripts/cleanup_drifts.R; ./scripts/cleanup_drifts.sh). The input file containing all drift_correction data can be found at ./_data/all_cleaned_drifts.csv. For each run a logistic model was built fitting the number of channels over time using the script: **./_scripts/DARIA**. All flow cell half-life values can be found at ./_data/halflifetimes_curated20230526.txt.
- **Number of sequenced bases**: The number of sequenced bases was obtained from the report markdown generated with each sequencing run using the script: ./_scripts/get_est_bases.sh. All data for how many bases were sequenced in each run can be found at ./_data/all_est_bases.csv.
- **Read length**: The average read length (arithmetic mean) for all reads of the respective sequencing runs was obtained from the **DARIA?** files and concatenated for all runs using the script: **./_scripts/DARIA**. All average read length values for each run can be found at ./_scripts/20230316_readLength.txt.

### Input data combined
- All wetlab and drylab input data were cleaned and combined into single dataframe using the script ./_data/make_master.Rmd. The dataframe can be found at ./_data/master_plus.RDS.

### Analyses
- The analyses for all Figures related to flow cell half-life were based on data at ./_analysis/master_plus.RDS. The code to reproduce the figures can be found at ./_analysis/nanopore_meta.Rmd

### Contact
- For any questions, please contact <daria.meyer@uni-jena.de>, <damian.wollny@uni-jena.de>, <manja@uni-jena.de>
