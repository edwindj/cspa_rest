#! Rscript
# linear rule checking
library(getopt)
library(rjson)
require(rspa)

spec = matrix(c(
  'data'  , 'i', 1, "character",  
  'localization'  , 'l', 1, "character",
  'rules' , 'r', 1, "character",
  'adjusted', 'a', 1, "character"
), byrow=TRUE, ncol=4)

opt <- getopt(spec)


# Define the Driver
main <- function(data_url, localization_url, rules_url, adjusted_file){
############################################################
# Driver function to rspa package function 'adjustRecords' #
############################################################

# Read the (error-affected) data
data <- read.csv(data_url,  sep = ";")

# Read the edits
rules <- read.csv(rules_url,  sep = ";")

# Read the localized variables
loc <- read.csv(localization_url, sep = ";")

# Create edit matrix
m.edit <- editmatrix(rules)

# Create adjust logical array
l.loc <- as.matrix(loc)

# Take care of NAs in data (if any): as they cannot be directly handled by rspa
# put them to zero
data[is.na(data)] <- 0
 
# Correct errors (assuming very low tolerance: tol=1E-12)
adj <- adjustRecords(E = m.edit, dat = data, adjust = l.loc, verbose = TRUE, tol=1E-12)

# Build output dataframe
data.out <- adj$adjusted

# Write out the errors
write.table(data.out, file= adjusted_file, sep= ";", col.names= TRUE, row.names= FALSE, quote= FALSE, na= "NA")
}

# Invoke the Driver
main(opt$data, opt$localization, opt$rules, opt$adjusted)

# data_url <- "file://example/input/data.csv"
# localization_url <- "file://example/input/localization.csv"
# rules_url <- "file://example/input/rules.csv"
# adjusted_file <-"example/result/adjusted.csv"
# main(data_url, rules_url, checks_file)