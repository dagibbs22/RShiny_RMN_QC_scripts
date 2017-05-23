library(shiny)
library(shinyFiles)
library(devtools)
source("testfunction_20170517.R")
#install_github("leppott/ContDataQC")
library("ContDataQC")

#setwd("C:/Users/dgibbs/Documents/Projects/Regional_Monitoring_Networks/Continuous_data_processing/RShiny RMN QC scripts/RMN_continuous_data_QC_20170515")


shinyServer(function(input, output, session) {

  #The name of the field which has the dates
  dateField <- reactive({
    dateList <- input$dateField
  })
  
  #Establishes the input spreadsheet. datasetInput is referred to in later sections.
  datasetInput <- reactive({
    infile <- input$file1
    if (is.null(infile))
      return(NULL)
    read.csv(infile$datapath, header=TRUE)
  })
  
  #Operation to be performed on the data (e.g., QC, aggregation)
  output$Operation <- renderText({paste("input$Operation is '",input$Operation,"'.",sep="")})
  
  #Type of data being input (e.g., air, water, air/water)
  output$DataType <- renderText({paste("input$DataType is '",input$DataType,"'.",sep="")})
  
  #Not currently in use
  output$BaseDir <- renderText(({paste("input$BaseDir is '",input$BaseDir,"'.",sep="")}))
  
  #Populates fields in the sidebar with the earliest and latest dates in the input spreadsheet
  output$dates <- renderUI({
    
    #Makes it so the sidebar doesn't show an error just because dates haven't been selected
    infile <- input$file1
    if (is.null(infile))
      return(NULL)
    
    #creates a copy of the input spreadsheet. Referred to later.
    measurements <- datasetInput()
    
    #Identifies the column number which has the dates 
    #based on the user's input of the name of the date field
    inDates <- input$dateField
    dateColNumb <- which(colnames(measurements)==inDates)
    
    #creates minimum and maximum dates from the user-indicated date field
    dates <- as.Date(datasetInput()[,dateColNumb], format = "%m/%d/%Y")
    minval <- min(dates)
    maxval <- max(dates)
    
    #Actually populates the user interface sidebar with the selected dates
    dateRangeInput("expDateRange", label = "Choose experiment time-frame:",
                   start = minval, end = maxval,
                   min = minval, max = maxval,
                   separator = " - ", format = "yyyy-mm-dd",
                   weekstart = 1
    )
  })
  
  #Creates a summary table of all input files
  #so users can check whether the right files are selected.
  #Each input spreadsheet gets one row.
  output$summaryTable <- renderTable({
    
    #Makes it so the table area doesn't show an error just because dates haven't been selected
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    
    #Creates a copy of the input spreadsheet. Referred to later.
    measurements <- datasetInput()
    
    #Identifies the column number which has the dates 
    #based on the user's input of the name of the date field
    inDates <- input$dateField
    dateColNumb <- which(colnames(measurements)==inDates)
    
    #Extracts the name of the file from the input file
    filename <- inFile$name
    
    #Extracts the station ID from the input file
    stationID <- measurements[1,2]

    #Calculates the starting and ending dates for each file
    #The date field is based on the user-input date field name
    dates <- as.Date(measurements[,dateColNumb], format = "%m/%d/%Y")
    minval <- which.min(as.Date(measurements[,dateColNumb], format = "%m/%d/%Y"))
    maxval <- which.max(as.Date(measurements[,dateColNumb], format = "%m/%d/%Y"))
    minDate <- measurements[minval,dateColNumb]
    maxDate <- measurements[maxval,dateColNumb]

    #Extracts how many records are in the spreadsheet
    recordCount <- nrow(measurements)
    
    #Creates the summary table with column headings
    summaryTable <- data.frame(filename, stationID, minDate, maxDate, recordCount)
    columns <- c("File name", "Station ID", "Starting date", "Ending date", "Record count")
    colnames(summaryTable) <- columns
    return(summaryTable)
    
  })
  
  #Purely for testing purposes. To make sure text is being interpreted properly.
  output$file <- renderText({
    inDates <- input$dateField
    measurements <- datasetInput()
    
    dateColNumb <- which(colnames(measurements)==inDates)
    #paste("This is for testing", inDates, dateColNumb)
    paste("This is for more testing", input$expDateRange[1], input$expDateRange[2])
  })
  
  #Prints the first four lines of the input spreadsheet. For testing purposes.
  output$contents <- renderTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$file1
        if (is.null(inFile))
      return(NULL)
    head(read.csv(inFile$datapath),4)
  })
  
  #Runs the selected process by calling on the QC script that Erik Leppo wrote
  observeEvent(input$runProcess, {
    
    #Creates a copy of the input spreadsheet. Referred to later.
    measurements <- datasetInput()
    
    #Identifies the field that has the station ID based on the user input
    inStationIDs <- input$stationIDField
    stationIDColNumb <- which(colnames(measurements)==inStationIDs)
    stationIDs <- measurements[1, stationIDColNumb]
    
    #Pulls in the starting and ending dates, which the user can modify but
    #are originally based on the first and last dates in the file
    firstDate <- as.character(input$expDateRange[1], format = "%Y/%m/%d")
    lastDate <- as.character(input$expDateRange[2], format = "%Y/%m/%d")

    #Invokes the QC/aggregate/summarize script
    ContDataQC(input$Operation, 
               stationIDs, 
               input$DataType, 
               firstDate,
               lastDate,
               "C:/Users/dgibbs/Documents/Projects/Regional_Monitoring_Networks/Continuous_data_processing/RShiny RMN QC scripts/RMN_continuous_data_QC_20170515", 
               "", 
               "")
  })
  
  #For testing purposes
  #output$table = DT::renderDataTable(datasetInput())
  
}##shinyServer.END
)
