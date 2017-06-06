library(shiny)
library(shinyFiles)
library(devtools)
#install_github("leppott/ContDataQC")
library(ContDataQC)
library(zoo)

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
    strFile.SiteID     <- strFile.parts[[1]][2]
    strFile.DataType   <- strFile.parts[[1]][3]
    # Convert Data Type to proper case
    strFile.DataType <- paste(toupper(substring(strFile.DataType,1,1)),tolower(substring(strFile.DataType,2,nchar(strFile.DataType))),sep="")
    strFile.Date.Start <- as.Date(strFile.parts[[1]][4],"%Y%m%d")
    strFile.Date.End   <- as.Date(strFile.parts[[1]][5],"%Y%m%d")
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


######FOR TESTING ONLY
library(vegan)

testFunc <- function(y,z) {
  x <- rpois (y, z)
  return (x)
}
div <- data.frame(x=c(0:50), y=c(100:150))


######Potentially useful code scraps
# #Populates fields in the sidebar with the earliest and latest dates in the input spreadsheet
# output$dates <- renderUI({
#   
#   #Makes it so the sidebar doesn't show an error just because dates haven't been selected
#   inFile <- input$file1
#   if (is.null(inFile))
#     return(NULL)
#   
#   #creates a copy of the input spreadsheet. Referred to later.
#   measurements <- datasetInput()
#   
#   #Identifies the column number which has the dates 
#   #based on the user's input of the name of the date field
#   inDates <- input$dateField
#   dateColNumb <- which(colnames(measurements)==inDates)
#   
#   #creates minimum and maximum dates from the user-indicated date field
#   dates <- as.Date(datasetInput()[,dateColNumb], format = "%m/%d/%Y")
#   minval <- min(dates)
#   maxval <- max(dates)
#   
#   #Actually populates the user interface sidebar with the selected dates
#   dateRangeInput("expDateRange", label = "Choose experiment time-frame:",
#                  start = minval, end = maxval,
#                  min = minval, max = maxval,
#                  separator = " - ", format = "yyyy-mm-dd",
#                  weekstart = 1
#   )
# })

# #Establishes the input spreadsheet. datasetInput is referred to in later sections.
# datasetInput <- reactive({
#   inFile <- input$selectedFiles
#   if (is.null(inFile))
#     return(NULL)
#   read.csv(inFile$datapath, header=TRUE)
# })