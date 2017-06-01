################################################################################
## Purpose: Prep LSMS surveys for analysis
## Date created: 
## Date modified:
## Author: Austin Carter, aucarter@uw.edu
## Run instructions: 
## Notes:
################################################################################

### Setup
rm(list=ls())
windows <- Sys.info()[1]=="Windows"
root <- ifelse(windows,"J:/","/home/j/")
user <- ifelse(windows, Sys.getenv("USERNAME"), Sys.getenv("USER"))
code.dir <- paste0(ifelse(windows, "H:", paste0("/homes/", user)), "/HIV/")

## Packages
library(data.table); library(haven)

## Arguments
# args <- commandArgs(trailingOnly = TRUE)
# if(length(args) > 0) {

# } else {

# }

### Paths
in.dir <- paste0(root, "Project/COMIND/Poverty/Extract Data/Datasets/")
out.path <- paste0(root, "Project/COMIND/Poverty/Extract Data/combined_LSMS.csv")

### Functions
source(paste0(code.dir, "shared_functions/get_locations.R"))

### Tables
loc.table <- get_locations()

### Code
file.list <- list.files(in.dir, "lsms", ignore.case = T)
dt.list <- lapply(file.list, function(file){
	# file <- file.list[15]
	print(file)
	split <- strsplit(file, "_")[[1]]
	loc <- toupper(split[1])
	year <- as.integer(split[2])
	in.path <- paste0(in.dir, file)
	dt <- data.table(read_dta(in.path))
	lapply(names(dt), function(var) {
		dt[, (var) := as.character(get(var))]
	})
	dt[, c("ihme_loc_id", "year") := .(loc, year)]
})
all.dt <- rbindlist(dt.list, use.names = T, fill = T)

write.csv(all.dt, out.path, row.names = F)
# Any variables included in all?
non.na <- sapply(names(all.dt), function(var) {
	!any(is.na(all.dt[[var]]))
})
which(non.na)
# Nope

# Proportion not NA
non.prop <- sapply(names(all.dt), function(var) {
	sum(!is.na(all.dt[[var]])) / nrow(all.dt) * 100
})
non.prop[non.prop > 50]
# Maybe just use variables with more than 50% completeness

### End