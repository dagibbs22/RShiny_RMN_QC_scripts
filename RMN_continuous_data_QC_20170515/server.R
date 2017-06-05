#Source of supporting functions
source("global.R")

shinyServer(function(input, output, session) {

  #Establishes the input spreadsheet. datasetInput is referred to in later sections.
  datasetInput <- reactive({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    read.csv(inFile$datapath, header=TRUE)
  })
  
  #Operation to be performed on the data (e.g., QC, aggregation)
  output$Operation <- renderText({paste("input$Operation is '",input$Operation,"'.",sep="")})

  #Not currently in use
  output$BaseDir <- renderText(({paste("input$BaseDir is '",input$BaseDir,"'.",sep="")}))
  
  #Populates fields in the sidebar with the earliest and latest dates in the input spreadsheet
  output$dates <- renderUI({
    
    #Makes it so the sidebar doesn't show an error just because dates haven't been selected
    inFile <- input$file1
    if (is.null(inFile))
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

    #Extracts the name of the file from the input file
    filename <- inFile$name

    #Runs a function to extract the station ID, data type, and start and
    #end dates from the input file name.
    #The returned object is a data.frame, in which each column has one
    #of the attributes.
    fileAttribs <- nameParse(filename, input$Operation)

    #Creates objects for the station ID, type of data in the file
    #(e.g., Air, Air & Water, Water) and start and end dates of
    #the file
    stationID <- fileAttribs[1,1]
    dataType <- fileAttribs[1,2]
    startDate <- fileAttribs[1,3]
    endDate <- fileAttribs[1,4]

    #Extracts how many records are in the spreadsheet
    recordCount <- nrow(measurements)

    #Creates the summary table with column headings
    summaryTable <- data.frame(inFile$datapath, filename, stationID, dataType, startDate, endDate, recordCount)
    columns <- c("Path", "File name", "Station ID", "Data type", "Starting date", "Ending date", "Record count")
    colnames(summaryTable) <- columns

    #Reformats the date columns to be the right date format
    summaryTable[,5] <- format(summaryTable[,5], "%Y-%m-%d")
    summaryTable[,6] <- format(summaryTable[,6], "%Y-%m-%d")

    return(summaryTable)

  })
  
  #FOR TESTING. To make sure text is being interpreted properly.
  output$file <- renderText({
    
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)

    #Creates a copy of the input spreadsheet. Referred to later.
    measurements <- datasetInput()

    #Extracts the name of the file from the input file
    filename <- inFile$name

    fileAttribs <- nameParse(filename, input$Operation)

    stationID <- fileAttribs[1,1]
    dataType <- fileAttribs[1,2]
    minval <- fileAttribs[1,3]
    maxval <- fileAttribs[1,4]

    paste("This is for more testing", input$val1, input$val2)
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
  
  
  #FOR TESTING ONLY
  values <- reactiveValues(df_data = NULL)
  values2 <- reactiveValues(df_data2 = NULL)
  
  #Runs the selected process by calling on the QC script that Erik Leppo wrote
  observeEvent(input$runProcess, {

    inFile <- input$file1

    #Extracts the name of the file from the input file
    filename <- inFile$name
    
    #Runs a function to extract the station ID, data type, and start and
    #end dates from the input file name.
    #The returned object is a data.frame, in which each column has one
    #of the attributes.
    fileAttribs <- nameParse(filename, input$Operation)
    
    #Creates objects for the station ID, type of data in the file
    #(e.g., Air, Air & Water, Water) and start and end dates of
    #the file
    stationID <- fileAttribs[1,1]
    dataType <- fileAttribs[1,2]
    startDate <- fileAttribs[1,3]
    endDate <- fileAttribs[1,4]
    
    stationID <- as.character(stationID)
    dataType <- as.character(dataType)
    startDate <- format(startDate, "%Y-%m-%d")
    endDate <- format(endDate, "%Y-%m-%d")
    
    #Renames the input and output folder objects
    inputFolder <- input$inputDir
    outputFolder <- input$outputDir
    
    #FOR TESTING ONLY
    val1b <- as.numeric(input$val1)
    val2b <- as.numeric(input$val2)
    values$df_data <- testFunc(val1b, val2b)
    values2$df_data2 <- head(diversity(div), val1b)
    
    #Invokes the QC/aggregate/summarize script
    ContDataQC(input$Operation,
               stationID,
               dataType,
               startDate,
               endDate,
               inputFolder,
               outputFolder,
               #"C:/Users/dgibbs/Documents/Projects/Regional_Monitoring_Networks/Continuous_data_processing/RShiny RMN QC scripts/RMN_continuous_data_QC_20170515/Data1_RAW",
               #"C:/Users/dgibbs/Documents/Projects/Regional_Monitoring_Networks/Continuous_data_processing/RShiny RMN QC scripts/RMN_continuous_data_QC_20170515/Data2_QC",
               "")
  })
  
  #FOR TESTING ONLY
  output$df_data2_out <- renderTable(values2$df_data2)
  
}##shinyServer.END
)
