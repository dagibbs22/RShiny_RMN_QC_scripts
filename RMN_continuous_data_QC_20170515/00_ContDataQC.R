# Manipulates Continuous Data Files (run different operations based on user input below)
# Erik.Leppo@tetratech.com (EWL), 2015-11-19
##################
# It is assumed that this R script is stored in a directory with the data files as subdirectories.
# If this script is run in TINN-R or R-Studio there is no need to define the working directory
#####################################################################
# clear the workspace
rm(list=ls())

#install if needed
library(devtools)
install_github("leppott/ContDataQC")
#
require("ContDataQC")


# Define working Directory
# if specify directory use "/" not "\" (as used in Windows) and leave off final "/" (example below).
#myDir.BASE  <- "C:/Users/Erik.Leppo/Documents/NCEA_DataInfrastructure/Erik"
#myDir.BASE <- getwd()
myDir.BASE <- "C:/Users/dgibbs/Documents/Projects/Regional_Monitoring_Networks/Continuous_data_processing/RShiny RMN QC scripts/RMN_continuous_data_QC_20170515"
setwd(myDir.BASE)
# library (load any required helper functions)
#source(paste(myDir.BASE,"Scripts","fun.Master.R",sep="/"))
#####################################################################
# USER input in this section (see end of script for explanations)
#####################################################################
#
# PROMPT; Operation
Selection.Operation <- c("GetGageData","QCRaw", "Aggregate", "SummaryStats")
myData.Operation    <- Selection.Operation[2]  #number corresponds to intended operation in the line above
#
# PROMPT; Site ID
# single site;         "ECO66G12"
# group of sites;      c("test2", "HRCC", "PBCC", "ECO66G12", "ECO66G20", "ECO68C20", "01187300")
myData.SiteID       <- "ECO66G12"
#
# PROMPT; Data Type
# Type of data file
Selection.Type      <- c("Air","Water","AW","Gage","AWG","AG","WG") # only one at a time
myData.Type         <- Selection.Type[3] #number corresponds to intended operation in the line above
#
# PROMPT; Start Date
# YYYY-MM-DD ("-" delimiter), leave blank for all data ("1900-01-01")
myData.DateRange.Start  <- "2013-01-01"
#
# PROMPT; End Date
# YYYY-MM-DD ("-" delimiter), leave blank for all data (today)
myData.DateRange.End    <- "2014-12-31"
######################################################################
# PROMPT; SubDirectory, input file location.  Leave blank for defaults
Selection.SUB <- c("Data1_RAW","Data2_QC","Data3_Aggregated","Data4_Stats")
myDir.SUB.import <- "" #Selection.SUB[2]
#
# PROMPT; SubDirectory, output file location.  Leave blank for default.
myDir.SUB.export <- "" #Selection.SUB[3]
#
#####################################################################
# Run the script with the above user defined values
ContDataQC(myData.Operation
           ,myData.SiteID
           ,myData.Type
           ,myData.DateRange.Start
           ,myData.DateRange.End
           ,myDir.BASE
           ,myDir.SUB.import
           ,myDir.SUB.export)
