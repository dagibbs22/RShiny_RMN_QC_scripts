#Developed by David Gibbs, ORISE fellow at the US EPA Office of Research & Development. dagibbs22@gmail.com
#Written 2017 and 2018

library(shiny) 
library(shinyFiles)
library(rmarkdown)
library(rsconnect)
library(ContDataQC)
library(zoo) 
library(shinythemes)
library(zip)

###For downloading new versions of ContDataQC and USGS' DataRetrieval package
#library(devtools)
#install_github("leppott/ContDataQC")
#install_github("USGS-R/dataRetrieval")

# #Seems necessary for making R able to zip files when run locally. Allows R to
# #access Window's zipping abilities
# Sys.setenv(PATH = paste(Sys.getenv("PATH"), "C:\\Rtools\\bin", sep = ";"))

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
  
  #Recognizes dates if they are in a Date field as opposed to a Date.Time field
  else if("Date" %in% colnames(inputFile)){
    startDate <-min(as.Date(inputFile$Date, format = "%m/%d/%Y"))
    endDate <- max(as.Date(inputFile$Date, format = "%m/%d/%Y"))
  }
  
  #Recognizes dates if they are in a "Date Time" field as opposed to a Date.Time field
  else if("Date Time" %in% colnames(inputFile)){
    startDate <-min(as.Date(inputFile$`Date Time`, format = "%m/%d/%Y"))
    endDate <- max(as.Date(inputFile$`Date Time`, format = "%m/%d/%Y"))
  }
  
  #Recognizes dates if they are in a Date.Time field
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

 
#Converts the more intuitive operation names into operation names that
#the ContDataQC() will recognize
renameOperation <- function(operation) {

  if (operation == "QC raw data") {
    operation <- "QCRaw"
  }
  
  else if (operation == "Aggregate QC'ed data") {
    operation <- "Aggregate"
  }
  
  else if (operation == "Summary statistics") {
    operation <- "SummaryStats"
  }
  
  else {
    operation <- ""
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

#Renames the outputs of the Aggregate process.
#Deletes the "append_x" part of the names (csv and html)
#and replaces that with the ending date of the latest file.
renameAggOutput <- function(directory, fileAttribsTable) {

  #All files in the working directory
  allFiles <- list.files(directory)
  
  #Creates vectors for the input and output files
  csvInputs <- vector()
  csvOutput <- vector()
  htmlOutput <- vector()
  
  #Populates vectors for the input and output files if the input files are
  #output from the Aggregate process
  if ("DATA_DATA" %in% substr(allFiles,1,9)){
    csvInputs <- list.files(directory, pattern = "^DATA_QC.*csv")
    csvOutput <- list.files(directory, pattern = "DATA_DATA_QC.*csv")
    htmlOutput <- list.files(directory, pattern = "DATA_DATA_QC.*html")
  } 
  
  #Populates vectors for the input and output files if the input files are
  #output from non-Aggregate processes
  else{
    #Gets the input csvs and output csv and HTML reports
    csvInputs <- list.files(directory, pattern = "^QC.*csv")
    csvOutput <- list.files(directory, pattern = "DATA_QC.*csv")
    htmlOutput <- list.files(directory, pattern = "DATA_QC.*html")
  }

  #For parsing the file names
  myDelim <- "_"

  #Creates vector for storing the data types for the input files
  data.type.inputs <- vector()
  
  #Extracts the data type from all input files
  for (i in 1:length(csvInputs)){
    csvInputs.parts <- strsplit(csvInputs[i], myDelim)
    data.type.inputs.number <- which(csvInputs.parts[[1]] == fileAttribsTable[1,2]) + 1
    data.type.inputs[i] <- csvInputs.parts[[1]][data.type.inputs.number]
  }
  
  #Gets the earliest and latest starting and ending dates for all input files
  minStartDate <- min(fileAttribsTable[,3])
  maxStartDate <- max(fileAttribsTable[,3])

  minEndDate <- min(fileAttribsTable[,4])
  maxEndDate <- max(fileAttribsTable[,4])

  #Changes the output file names if the input files have different data types 
  #and have the same start and end dates
  if(data.type.inputs[1] != data.type.inputs[2]
     && minStartDate == maxStartDate
     && minEndDate == maxEndDate){
    
    #Creates a data.frame for converting the input data types to the output data type
    first.data.type <-      c("A",  "A",  "W",  "W",  "G",  "G",  "AW", "AW",  "AG",  "WG",  "G",   "W",   "A")
    second.data.type <-     c("W",  "G",  "A",  "G",  "A",  "W",  "AW", "G",   "W",   "A",   "AW",  "AG",  "WG")
    combined.data.type <-   c("AW", "AG", "AW", "WG", "AG", "WG", "AW", "AWG", "AWG", "AWG", "AWG", "AWG", "AWG")
    data.type.conversion <- data.frame(first.data.type, second.data.type, combined.data.type)
    
    #Finds the rows in the conversion data.frame which have that date type
    type1 <- which(data.type.conversion[,1]==data.type.inputs[1])
    type2 <- which(data.type.conversion[,2]==data.type.inputs[2])

    #Finds the one row on the conversion data.frame that corresponds to those data types
    output.type <- as.character(data.type.conversion[intersect(type1, type2), 3])

    #Changes the data type in the output csv to the correct datatype
    csvOutput.data.type <- gsub(paste("_", data.type.inputs[1], "_", sep=""), 
                                paste("_", output.type, "_", sep=""), 
                                csvOutput)
    
    #Sometimes the Aggregate process uses the second data type in its output name.
    #This captures that eventuality.
    csvOutput.data.type <- gsub(paste("_", data.type.inputs[2], "_", sep=""), 
                                paste("_", output.type, "_", sep=""), 
                                csvOutput.data.type)

    #Removes the "_append_x" from the output csv name
    csvOutput.data.type <- gsub(paste("_Append_", length(csvInputs), sep=""), 
                                paste("", sep=""), 
                                csvOutput.data.type)

    #Renames the csv
    file.rename(csvOutput, csvOutput.data.type)
    
    
    #Changes the data type in the output html to the correct datatype
    htmlOutput.data.type <- gsub(paste("_", data.type.inputs[1], "_", sep=""),
                                paste("_", output.type, "_", sep=""),
                                htmlOutput)
    
    #Sometimes the Aggregate process uses the second data type in its output name.
    #This captures that eventuality.
    htmlOutput.data.type <- gsub(paste("_", data.type.inputs[2], "_", sep=""),
                                 paste("_", output.type, "_", sep=""),
                                 htmlOutput.data.type)

    #Removes the "_append_x" from the output html name
    htmlOutput.data.type <- gsub(paste("_Append_", length(csvInputs), sep=""),
                                paste("", sep=""),
                                htmlOutput.data.type)
    
    #Removes the "_Report_Aggregate" from the output html name
    htmlOutput.data.type <- gsub(paste("_Report_Aggregate", sep=""),
                                 paste("", sep=""),
                                 htmlOutput.data.type)

    #Renames the html output
    file.rename(htmlOutput, htmlOutput.data.type)
    
  } 
  
  #Changes the output file names if the input files are from different time periods
  else {
  
    #Identifies the minimum and maximum dates in all input files
    minDate <- min(fileAttribsTable[,3])
    minDate <- gsub("-", "", minDate)
    
    maxDate <- max(fileAttribsTable[,4])
    maxDate <- gsub("-", "", maxDate)
  
    #The number of csv files input to the Aggregate step
    numFiles <- length(csvInputs)
    
    #Determines how many characters should be removed from end of csv output name
    #(through the (inaccurate) second date in the name, which is not the latest
    #date of measurement)
    csvCharsToRemove <- 8+1+8+1+6+1+nchar(numFiles)+4
  
    #Removes the specified number of characters
    csvNewName <- substr(csvOutput, 0, nchar(csvOutput)-csvCharsToRemove)
  
    #Adds the last recorded date to the truncated file name
    csvNewName <- paste(csvNewName, minDate, "_", maxDate, ".csv", sep="")
  
    #Replaces the old file name with the new one
    file.rename(csvOutput, csvNewName)
  
    #Same as above but for the HTML reports
    htmlCharsToRemove <- 8+1+8+1+6+1+nchar(numFiles)+1+6+1+8+6
    htmlNewName <- substr(htmlOutput, 0, nchar(htmlOutput)-htmlCharsToRemove)
    htmlNewName <- paste(htmlNewName, minDate, "_", maxDate, ".html", sep="")
    file.rename(htmlOutput, htmlNewName)
  
  }

}


######Not currently using
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