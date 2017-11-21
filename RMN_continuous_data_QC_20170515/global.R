library(shiny) 
library(shinyFiles)
library(devtools)
library(rmarkdown)
library(rsconnect)
#install_github("leppott/ContDataQC")
library(ContDataQC)
library(zoo) 

#Seems necessary for making R able to zip files when run locally. Allows R to
#access Window's zipping abilities
Sys.setenv(PATH = paste(Sys.getenv("PATH"), "C:\\Rtools\\bin", sep = ";"))

#Maximum individual file size that can be uploaded is 35 MB
options(shiny.maxRequestSize=70*1024^2)

#Names the data template spreadsheet
dataTemplate <- read.csv(file="continuous_data_template_2017_11_15.csv", header=TRUE)

#Extracts properties of the input spreadsheets
fileParse <- function(inputFile) {

  #Extracts site ID, start and end dates, and record count.
  #These are all for the first summary table.
  siteID <- as.character(inputFile$SiteID[2])
  recordCount <- nrow(inputFile)
  
  #Dates are formatted differently for data input to QCRaw and data input
  #to Aggregate and Summarize (output from QCRaw)
  if("Flag" %in% substr(colnames(inputFile),1,4)) {
    startDate <-min(as.Date(inputFile$Date.Time, format = "%Y-%m-%d"))
    endDate <- max(as.Date(inputFile$Date.Time, format = "%Y-%m-%d"))
  } 
  else {
    startDate <-min(as.Date(inputFile$Date.Time, format = "%m/%d/%Y"))
    endDate <- max(as.Date(inputFile$Date.Time, format = "%m/%d/%Y"))
  }
  
  #Extracts which parameters are included in the spreadsheet.
  #These are all for the second summary table
  #Provides default values (parameter not found).
  waterTemp <- "Not found"
  airTemp <- "Not found"
  waterPressure <- "Not found"
  airPressure <- "Not found"
  sensorDepth <- "Not found"
  gageHeight <- "Not found"
  flow <- "Not found"
  
  #Changes the table's value to "found" if the
  #paramete is identified
  if("Water.Temp.C" %in% colnames(inputFile)) {
    waterTemp <- "Found"
  }
  
  if("Air.Temp.C" %in% colnames(inputFile)) {
    airTemp <- "Found"
  }
  
  if("Water.P.psi" %in% colnames(inputFile)) {
    waterPressure <- "Found"
  }
  
  if("Air.BP.psi" %in% colnames(inputFile)) {
    airPressure <- "Found"
  }
  
  if("Sensor.Depth.ft" %in% colnames(inputFile)) {
    sensorDepth <- "Found"
  }
  
  if("GageHeight" %in% colnames(inputFile)) {
    gageHeight <- "Found"
  }
  
  if("Discharge" %in% colnames(inputFile)) {
    flow <- "Found"
  }

  #Compiles all spreadsheet properties into a single data.frame
  siteDF <- data.frame(siteID, startDate, endDate, 
                recordCount, waterTemp, airTemp, 
                waterPressure, airPressure, sensorDepth, gageHeight, flow)

  return(siteDF)
}

 
#Function to parse out the station ID, data type, and starting and ending
#dates from the input file name.
#This is copied from the filename parser used by the QC script itself.
#It exports a data.frame in which each property is its own column.
#It extracts file information differently based on what process is being run
nameParse <- function(strFile, process) {
  
  #Sets up the parsing
  myDelim <- "_"
  strFile.Base <- substr(strFile,1,nchar(strFile)-nchar(".csv"))
  strFile.parts <- strsplit(strFile.Base, myDelim)

  #Parsing for the Aggregate step. Files being aggregated have "QC_" prepended.
  if (process == "Aggregate") {
    strFile.SiteID     <- strFile.parts[[1]][2]
    strFile.DataType   <- strFile.parts[[1]][3]
    # Convert Data Type to proper case
    strFile.DataType <- paste(toupper(substring(strFile.DataType,1,1)),tolower(substring(strFile.DataType,2,nchar(strFile.DataType))),sep="")
    strFile.Date.Start <- as.Date(strFile.parts[[1]][4],"%Y%m%d")
    strFile.Date.End   <- as.Date(strFile.parts[[1]][5],"%Y%m%d")
  }

  #Parsing for the SummaryStats step. Files being aggregated have "DATA_" prepended.
  else if (process == "SummaryStats") {
    strFile.SiteID     <- strFile.parts[[1]][3]
    strFile.DataType   <- strFile.parts[[1]][4]
    # Convert Data Type to proper case
    strFile.DataType <- paste(toupper(substring(strFile.DataType,1,1)),tolower(substring(strFile.DataType,2,nchar(strFile.DataType))),sep="")
    strFile.Date.Start <- as.Date(strFile.parts[[1]][5],"%Y%m%d")
    strFile.Date.End   <- as.Date(strFile.parts[[1]][6],"%Y%m%d")
  }

  #Parsing for the QCRaw or GetgageData steps.
  else {
    strFile.SiteID     <- strFile.parts[[1]][1]
    strFile.DataType   <- strFile.parts[[1]][2]
    # Convert Data Type to proper case
    strFile.DataType <- paste(toupper(substring(strFile.DataType,1,1)),tolower(substring(strFile.DataType,2,nchar(strFile.DataType))),sep="")
    strFile.Date.Start <- as.Date(strFile.parts[[1]][3],"%Y%m%d")
    strFile.Date.End   <- as.Date(strFile.parts[[1]][4],"%Y%m%d")
  }
  
  siteDF <- data.frame(strFile.SiteID, strFile.DataType, strFile.Date.Start, strFile.Date.End)

  return(siteDF)
}

#Converts the more intuitive operation names into operation names that
#the ContDataQC() will recognize
renameOperation <- function(operation) {
  if (operation == "Get gage data") {
    operation <- "GetGageData"
  }
  
  else if (operation == "QC raw data") {
    operation <- "QCRaw"
  }
  
  else if (operation == "Aggregate QC'ed data") {
    operation <- "Aggregate"
  }
  
  else {
    operation <- "SummaryStats"
  }
}

#Formats the date-time of the output file download 
timeFormatter <- function(time) {
  time2 <- gsub(":", "_", time)
  time3 <- gsub("-", "", time2)
  time4 <- gsub(" ", "_", time3)
  return(time4)
}

#Converts a string of USGS site IDs (comma delimited)
#into an array of site IDs for gage data retrieval
USGSsiteParser <- function(siteIDs) {
  USGSsiteVector <- unlist(strsplit(siteIDs, split=", "))
  return(USGSsiteVector)
}

#Deletes the input csvs and output QC csvs and Word reports from the server after each download
#(actually, after new data are uploaded)
deleteFiles <- function(directory, inputFiles) {
  
  # #Lists the paths and names of the input csvs
  csvsInputsToDelete <- substring(list.files(path = directory, pattern = "QC.*csv", full.names = FALSE), 4)
  csvsInputsToDelete <- paste(directory, csvsInputsToDelete, sep="/")
  
  #Lists all the output csvs and QC Word documents on the server from QCRaw 
  csvsOutputsToDelete <- list.files(path = directory, pattern = "QC.*csv", full.names = TRUE)
  htmlOutputsToDelete <- list.files(path = directory, pattern = ".*html", full.names = TRUE)
  pdfOutputsToDelete <- list.files(path = directory, pattern = ".*pdf", full.names = TRUE)
  logOutputsToDelete <- list.files(path = directory, pattern = ".*tab", full.names = TRUE)
  gageOutputsToDelete <- list.files(path = directory, pattern = ".*Gage.*csv", full.names = TRUE)
  inputsToDelete <- paste(directory, inputFiles, sep="/")

  #Actually deletes the files
  file.remove(csvsOutputsToDelete)
  file.remove(htmlOutputsToDelete)
  file.remove(pdfOutputsToDelete)
  file.remove(logOutputsToDelete)
  file.remove(csvsInputsToDelete)
  file.remove(gageOutputsToDelete)
}