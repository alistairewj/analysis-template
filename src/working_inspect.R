# Libraries
library(assertthat)
library(devtools)
library(data.table)
library(yaml)
install_github("CC-HIC/ccdata") # will only install if there is an update
library(ccdata)

# ccfun library
install_github("CC-HIC/ccfun") # will only install if there is an update
library(ccfun)

# Load data
cc <- readRDS(file="../data/cc.RDS")
data_fields <- yaml::yaml.load_file("../config/data_fields.yaml")
ccfun::relabel_cols(cc, "NHICcode", "shortName", dict=data_fields)

# Create a patient level table
cc.patients <- cc[,head(.SD,1),by=.(site,episode_id)]
table(cc.patients$sex)
table(cc.patients$dead_icu)

# Inspect 2d fields
summary(cc$hrate)