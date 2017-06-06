#Source of supporting functions
source("global.R")

shinyServer(function(input, output, session) {

  #Operation to be performed on the data (e.g., QC, aggregation)
  output$Operation <- renderText({paste("input$Operation is '",input$Operation,"'.",sep="")})

  #Creates a summary table of all input files
  #so users can check whether the right files are selected.
  #Each input spreadsheet gets one row.
  output$summaryTable <- renderTable({

    #Makes it so the table area doesn't show an error just because input files haven't been selected yet
    if (is.null(input$selectedFiles))
      return(NULL)
    
    #Initializes the summary table
    summaryTable <- data.frame(filename = character(), 
                               stationID = character(),
                               dataType = character(),
                               startDate = as.Date(character()),
                               endDate = as.Date(character()))
   
    #All the selected input files are in a data.frame
    allFiles <- input$selectedFiles
    
    #Iterates through all the selected files in the data.frame 
    #to extract information from them
    for (i in 1:nrow(allFiles)) {

      #The file currently being extractd from
      inFile <- allFiles[i, ]
      
      #Extracts the name of the file from the input file
      filename <- inFile$name
  
      operation <- renameOperation(input$Operation)
      
      #Runs a function to extract the station ID, data type, and start and
      #end dates from the input file name.
      #The returned object is a data.frame, in which each column has one
      #of the attributes.
      fileAttribs <- nameParse(filename, operation)

      #Creates objects for the station ID, type of data in the file
      #(e.g., Air, Air & Water, Water) and start and end dates of
      #the file
      stationID <- fileAttribs[1,1]
      dataType <- fileAttribs[1,2]
      startDate <- fileAttribs[1,3]
      endDate <- fileAttribs[1,4]

      #Extracts how many records are in the spreadsheet
      actualData <- read.csv(inFile$datapath, header=TRUE)
      recordCount <- nrow(actualData)

      #Adds this input file's information to the summary table
      summaryRow <- data.frame(filename, stationID, dataType, startDate, endDate, recordCount)
      summaryTable <- rbind(summaryTable, summaryRow)
    }
    
    #Creates column names for the summary table
    columns <- c("File name", "Station ID", "Data type", "Starting date", "Ending date", "Record count")
    colnames(summaryTable) <- columns

    #Reformats the date columns to be the right date format
    summaryTable[,4] <- format(summaryTable[,4], "%Y-%m-%d")
    summaryTable[,5] <- format(summaryTable[,5], "%Y-%m-%d")

    return(summaryTable)

  })
  
  #FOR TESTING. To make sure text is being interpreted properly.
  output$testText <- renderText({
    
    inFile <- input$selectedFiles
    if (is.null(inFile))
      return(NULL)

    #Extracts the name of the file from the input file
    filename <- inFile$name

    fileAttribs <- nameParse(filename, input$Operation)

    stationID <- fileAttribs[1,1]
    dataType <- fileAttribs[1,2]
    minval <- fileAttribs[1,3]
    maxval <- fileAttribs[1,4]

    paste("This is for more testing:", minval, maxval)
  })
  
  # #Prints the first four lines of the input spreadsheet. For testing purposes.
  # output$contents <- renderTable({
  #   # input$selectedFiles will be NULL initially. After the user selects
  #   # and uploads a file, it will be a data frame with 'name',
  #   # 'size', 'type', and 'datapath' columns. The 'datapath'
  #   # column will contain the local filenames where the data can
  #   # be found.
  #   inFile <- input$selectedFiles
  #       if (is.null(inFile))
  #     return(NULL)
  #   head(read.csv(inFile$datapath),4)
  # })

  #Runs the selected process by calling on the QC script that Erik Leppo wrote
  observeEvent(input$runProcess, {

    #Converts the more user-friendly input operation name to the name
    #that ContDataQC() understands
    operation <- renameOperation(input$Operation)
    
    #Renames the data.frame of input files
    inFile <- input$selectedFiles

    #Extracts the name of the file from the input file
    filename <- inFile$name

    #Runs a function to extract the station ID, data type, and start and
    #end dates from the input file name.
    #The returned object is a data.frame, in which each column has one
    #of the attributes.
    fileAttribs <- nameParse(filename, operation)
    
    #Creates objects for the station ID, type of data in the file
    #(e.g., Air, Air & Water, Water) and start and end dates of
    #the file
    stationID <- fileAttribs[1,1]
    dataType <- fileAttribs[1,2]
    startDate <- fileAttribs[1,3]
    endDate <- fileAttribs[1,4]
    
    #Formats the file properties correctly
    stationID <- as.character(stationID)
    dataType <- as.character(dataType)
    startDate <- format(startDate, "%Y-%m-%d")
    endDate <- format(endDate, "%Y-%m-%d")
    
    #Renames the input and output folder objects
    inputFolder <- input$inputDir
    outputFolder <- input$outputDir
    
    #Invokes the QC/aggregate/summarize script
    ContDataQC(operation,
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

}
)
