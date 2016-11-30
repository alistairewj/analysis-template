# Libraries
library(assertthat)
install_github("CC-HIC/ccdata") # will only install if there is an update
library(ccdata)

# ccfun library
install_github("CC-HIC/ccfun") # will only install if there is an update
library(ccfun)

# Load data
cc <- readRDS(file="../data/cc-derived.RDS")
data_fields <- yaml::yaml.load_file("../config/data_fields.yaml")

# Create a patient level table
cc.patients <- cc[,head(.SD,1),by=.(site,episode_id)]
table(cc.patients$sex)
summary(as.double(cc.patients$age))
table(cc.patients$dead_icu)

# Inspect 2d fields
summary(cc$hrate)
summary(cc$time)

# Demonstrate heart rate over time
library(ggplot2)
ggplot(data=cc[episode_id %in% sample(unique(cc$episode_id),10)],
    aes(x=time, y=hrate,
    group=episode_id,
    colour=as.factor(episode_id))) + geom_smooth() +
    theme_minimal()


summary(cc$tidal.vol)
summary(cc$pf)
ggplot(data=cc, aes(x=tidal.vol)) +
    geom_density() +
    coord_cartesian(x=c(0,1000)) +
    theme_minimal()

d <- na.omit(cc[,.(tidal.vol, pf)])
ggplot(data=d, aes(x=pf, y=tidal.vol)) +
    geom_point() +
    # geom_smooth(method="lm", formula=y~poly(x,2), se=FALSE) +
    geom_smooth(method="loess", span=0.4, se=FALSE) +
    coord_cartesian(x=c(0,60), y=c(0,1000)) +
    theme_minimal()


