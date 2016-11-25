# Libraries

library(devtools)
library(data.table)
library(yaml)

install_github("CC-HIC/ccdata") # will only install if there is an update
library(ccdata)

# Data
# You need to make sure a file containing a ccRecord object is available
# This is (normally) named `ccd`
load("../data-raw/anon_ccd_k_5.RData")

# Data fields with configuration
data_fields <- yaml::yaml.load_file("../config/data_fields.yaml")

# Create ccTable object with items in yaml conf with cadence of 1 hour.
cct <- create.cctable(ccd, freq=1, conf=data_fields)

# Original (raw) data
str(cct$torigin)

# Clean data
cct$filter.ranges("red")
cct$filter.category()
cct$filter.nodata()
cct$filter.missingness()

# Report validation
cct$dfilter

# Specifically examine for missingness
cct$dfilter$missingness$episode
cct$get.missingness() 

# Apply validation to original data
cct$apply.filters()

# Impute 2d data as per specification
cct$imputation()

# Save complete data with cleaning audit trail
saveRDS(cct, file="../data/cct.RDS")

# Extract and save cleaned, validated and imputed data
cc <- copy(cct$tclean)
saveRDS(cc, file="../data/cc.RDS")


