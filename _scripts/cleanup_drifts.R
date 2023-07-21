# load libraries
suppressMessages(library(dplyr))
suppressMessages(library(data.table))
suppressMessages(library(here))

# open drift file
working_dir <- here()

# read command line arguments
args <- commandArgs(trailingOnly = T)

csv_file <- fread(file = Sys.glob(args))
print("opened file")

# if file contains a column called "X" -> remove that column
# then save new table in "_new" folder or copy old table in "_new" folder
clean_drift <- csv_file %>% 
  select_if(!names(.) %in% c('V1', 'drift', 'pa_corrected'))

# Print the name of the column that is removed (if any)
print(paste("Removed column(s):",
            colnames(csv_file)[which(names(csv_file) %in% c('V1', 'drift', 'pa_corrected'))]
))

# Print the number of remaining columns (sanitiy check)
print(paste("COLNUMBER:", length(colnames(clean_drift))))

# save clean drift file
write.csv(clean_drift, file = paste(args, "_cleaned", sep = ""), row.names=FALSE)