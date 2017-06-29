#Source of supporting functions
source("global.R")

shinyServer(function(input, output, session) {

  output$tableHeader <- renderText("Summary table of input files")
  
  #Creates a summary data.frame as a reactive object
  table <- reactive({

    #Shows the table headings before files are input
    if (is.null(input$selectedFiles)) {
      
      #Creates empty table columns
      nullTable <- data.frame(filenameNull = c("Awaiting data"), 
                              stationIDNull = c("Awaiting data"),
                              dataTypeNull = c("Awaiting data"),
                              startDateNull = c("Awaiting data"),
                              endDateNull = c("Awaiting data"),
                              recCountNull = c("Awaiting data"))
      
      #Creates column names and adds them to the table
      columns <- c("File name", "Station ID", "Data type", "Starting date", "Ending date", "Record count")
      colnames(nullTable) <- columns
      
      #Sends the empty table to be displayed
      return(nullTable)
    } 
    
    #Initializes the summary table
    summaryTable <- data.frame(filename = character(), 
                               stationID = character(),
                               dataType = character(),
                               startDate = as.Date(character()),
                               endDate = as.Date(character()),
                               recordCount = as.integer())
    
    #All the selected input files are in a data.frame
    allFiles <- input$selectedFiles
    
    #Iterates through all the selected files in the data.frame 
    #to extract information from them
    for (i in 1:nrow(allFiles)) {
      
      #The file currently being extracted from
      inFile <- allFiles[i, ]
      
      #Extracts the name of the file from the input file
      filename <- inFile$name
      
      #Renames the user-selected opertion from something user-friendly
      #to what ContDataQC can understand
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
  
  #Outputs a summary table of all input files
  #so users can check whether the right files are selected.
  #Each input spreadsheet gets one row.
  output$summaryTable <- renderTable({
    table()
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
    
    #Extracts the earliest starting date and latest ending date
    #from all input spreadsheets
    table <- table()
    startDates <- table[,4]
    endDates <- table[,5]
    firstDate <- startDates[order(format(as.Date(startDates), "%Y-%m-%d"))[1]]
    lastDate <- endDates[order(format(as.Date(endDates), "%Y-%m-%d"))[length(endDates)]]

    paste("This is for more testing:", input$inputDir, input$outputDir)
  })

  #Runs the selected process by calling on the QC script that Erik Leppo wrote
  observeEvent(input$runProcess, {

    #Converts the more user-friendly input operation name to the name
    #that ContDataQC() understands
    operation <- renameOperation(input$Operation)
    
    #Renames the input and output folder objects
    inputFolder <- input$inputDir
    outputFolder <- input$outputDir
    
    #All the selected input files are in a data.frame
    allFiles <- input$selectedFiles
    
    #Creates a data.frame for the R console output of the ContDataQC() script
    console$disp <- data.frame(consoleOutput = character())
    
    #Progress bar to tell the user the operation is running
    #Taken from https://shiny.rstudio.com/articles/progress.html
    withProgress(message = paste("Running", operation), value = 0, {
    
      #A short pause before the operation begins
      Sys.sleep(2)
      
      #Aggregating files requires having all the file names in a single string input for fun.myFile.
      #Thus, all files selected to be aggregated have their names put into a string.
      if (operation == "Aggregate") {

        #All the filenames selected for input
        fileNames <- allFiles$name
        
        #Turns the matrix of filenames into a string of filenames
        fileNameVector <-  as.vector(fileNames)
        
        #Changes the status bar to say that aggregation is occurring
        incProgress(0, detail = paste("Aggregating files"))
        
        #Saves the R console output of ContDataQC()
        consoleRow <- capture.output(
          
                        #Runs aggregation part of ContDataQC() on the input files
                        ContDataQC(operation, 
                        fun.myDir.import = inputFolder,
                        fun.myDir.export = outputFolder,
                        fun.myFile = fileNameVector
                        )
        )
        
        #Appends the R console output generated from that input file to the 
        #console output data.frame
        consoleRow <- data.frame(consoleRow)
        console$disp <- rbind(console$disp, consoleRow)
        
        #Fills in the progress bar once the operation is complete
        incProgress(1, detail = paste("Finished aggregating files"))
        
        #Pauses the progress bar once it's done
        Sys.sleep(2)
        
        #Names the single column of the R console output data.frame
        colnames(console$disp) <- c("R console output for all input files:")
        
      }
      
      #The QCRaw and Summarize functions can be fed individual input files
      #in order to have the progress bar incremement after each one is processed
      else {

        #Iterates through all the selected files in the data.frame 
        #to perform the QC script on them individually
        for (i in 1:nrow(allFiles)) {
          
          #The file currently being extractd from
          inFile <- allFiles[i, ]
          
          #Extracts the name of the file from the input file
          fileName <- inFile$name
          
          #Changes the status bar to say that the process is occurring
          incProgress(0, detail = paste("Operating on", fileName))

          #Saves the R console output of ContDataQC()
          consoleRow <- capture.output(
            
                          #Runs ContDataQC() on an individual file
                          ContDataQC(operation,
                          fun.myDir.import = inputFolder,
                          fun.myDir.export = outputFolder,
                          fun.myFile = fileName
                          )
          )

          #Appends the R console output generated from that input file to the 
          #console output data.frame
          consoleRow <- data.frame(consoleRow)
          console$disp <- rbind(console$disp, consoleRow)
          
          #Fills in the progress bar once the operation is complete
          incProgress(1/nrow(allFiles), detail = paste("Finished", fileName))
          
          #Pauses the progress bar once it's done
          Sys.sleep(2)
          
        }
        
        #Names the single column of the R console output data.frame
        colnames(console$disp) <- c("R console output for all input files:")

      }

    })
    
  })
  
  #Shows the output notes from ContDataQC from the R console in R Shiny
  console <- reactiveValues()
  
  output$logText <- renderTable({

    if (is.null(input$selectedFiles))
      return(NULL)

    return(console$disp)
    
  })
  

    
  # #Runs the selected process by calling on the QC script that Erik Leppo wrote
  # observeEvent(input$runProcess, {
  #     
  #   #Converts the more user-friendly input operation name to the name
  #   #that ContDataQC() understands
  #   operation <- renameOperation(input$Operation)
  #     
    # #Renames the data.frame of input files
    # inFile <- input$selectedFiles
    # 
    # #Extracts the name of the file from the input file
    # filename <- inFile$name
    # 
    # #Runs a function to extract the station ID, data type, and start and
    # #end dates from the input file name.
    # #The returned object is a data.frame, in which each column has one
    # #of the attributes.
    # fileAttribs <- nameParse(filename, operation)
    # 
    # #Creates objects for the station ID, type of data in the file
    # #(e.g., Air, Air & Water, Water) and start and end dates of
    # #the file
    # stationID <- fileAttribs[1,1]
    # dataType <- fileAttribs[1,2]
    # 
    # #Formats the file properties correctly
    # stationID <- as.character(stationID)
    # dataType <- as.character(dataType)
    # 
    # #Extracts the earliest starting date and latest ending date
    # #from all input spreadsheets. These set the date bounds over which
    # #the selected procedure will be run.
    # table <- table()
    # startDates <- table[,4]
    # endDates <- table[,5]
    # firstDate <- startDates[order(format(as.Date(startDates), "%Y-%m-%d"))[1]]
    # lastDate <- endDates[order(format(as.Date(endDates), "%Y-%m-%d"))[length(endDates)]]
    # 
    # #Renames the input and output folder objects
    # inputFolder <- input$inputDir
    # outputFolder <- input$outputDir
    # 
    # #Progress bar to tell the user the operation is running
    # #Taken from https://shiny.rstudio.com/articles/progress.html
    # withProgress(message = paste("Running", operation), value = 0, {
    # 
    #     #Invokes the QC/aggregate/summarize script
    #     ContDataQC(operation,
    #                stationID,
    #                dataType,
    #                firstDate,
    #                lastDate,
    #                inputFolder,
    #                outputFolder,
    #                "")
    # 
    # #Fills in the progress bar once the operation is complete
    # incProgress(1, detail = paste(operation, "complete"))
    # Sys.sleep(2.5)
    # 
    # })
  #   
  # })

}
)
