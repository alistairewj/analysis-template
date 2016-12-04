# Derive secondary variables
# ccfun library
library(ccfun)
library(assertthat)
install_github("CC-HIC/ccfun") # will only install if there is an update

# Load data
cc <- readRDS(file="../data/cc.RDS")
data_fields <- yaml::yaml.load_file("../config/data_fields.yaml")
ccfun::relabel_cols(cc, "NHICcode", "shortName", dict=data_fields)

# Simple episode level ID
cc[, id := episode_id]

# Simple ICU mortality marker
gen_mortality(cc, "mort.icu", "dead_icu")
table(unique(cc[,.(id,mort.icu)])$mort.icu)

# Male
cc[tolower(sex)=="m", male := TRUE ]
cc[tolower(sex)=="f", male := FALSE ]
table(unique(cc[,.(id,male)])$male)

library(lubridate)
str(cc[,.(icu_stop, icu_start)])
cc[, los.icu := ymd_hms(icu_stop)-ymd_hms(icu_start)]
# Report los.icu in days
summary(as.numeric(cc$los.icu)/(60*24))


cc[, d.bp_m_n := gen_map(bp_sys_ni, bp_dia_ni) ]
cc[, d.bp_m_a := gen_map(bp_sys_a, bp_dia_a) ]
cc[, map := choose_first_nonmissing(data.frame(bp_m_a, bp_m_ni, d.bp_m_a, d.bp_m_n))]
cc[, d.bp_m_n := NULL]
cc[, d.bp_m_a := NULL]
summary(cc$map)

# Generate ventilated indicator
# cc[, `:=`(roll=NULL, rollends=NULL, ppv=NULL)]
gen_ppv(cc, time, id, rr.vent)
table(cc$ppv)

# - [ ] NOTE(2016-11-30): NA will be returned if variables not concurrent
# Generate SOFA scores
gen_sofa_c(cc, map_=map, norad_=rx_norad, adr_=rx_adre, dopa_=rx_dopa, dobu_=rx_dobu)
table(cc$sofa_c, useNA="always")

cc[,pf := pao2/fio2 * 100]
gen_sofa_r(cc, pf_ = pf, ppv_ = ppv)
table(cc$sofa_r, useNA="always")

gen_sofa_h(cc, platelets_ = platelets)
table(cc$sofa_h, useNA="always")

gen_sofa_k(cc, creat_ = creatinine)
table(cc$sofa_k, useNA="always")

table(cc$gcs)
clean_gcs(cc, sedatives_=c("propofol", "fentanyl"))
table(cc$gcs.clean)
gen_sofa_n(cc, gcs_ = gcs.clean)
table(cc$sofa_n, useNA="always")

gen_sofa_l(cc, bili_ = bili)
table(cc$sofa_l, useNA="always")

sofa.cols <- c("sofa_c", "sofa_r", "sofa_h", "sofa_k", "sofa_n", "sofa_l")
cc[, sofa := rowSums(.SD, na.rm=TRUE), .SDcols=sofa.cols]
table(cc$sofa)

saveRDS(cc, file="../data/cc-derived.RDS")
