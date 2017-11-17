#Source of supporting functions 
source("global.R")
 
shinyServer(function(input, output, session) {

  ###Downloads data template
  #To allow users to download a properly formatted template of the continuous data spreadsheet
  output$downloadTemplate <- downloadHandler(
      filename <- function() {
        paste("continuous_data_template", "csv", sep=".")
      },
      
      content <- function(file) {
        write.csv(dataTemplate, file)
      }
    )
  
  
  ###Defines objects for the whole app
  #Creates a reactive object with all the input files
  allFiles <- reactive({
    allFiles <- input$selectedFiles
    if(is.null(allFiles)) return(NULL)
    return(allFiles)
  })

  #Creates a reactive object with all the input files' names
  UserFile_Name <- reactive({
    if(is.null(allFiles())) return(NULL)
    return(allFiles()$name)
  })
  
  #Creates a reactive object with all the input files' directories
  UserFile_Path <- reactive({
    if(is.null(allFiles())) return(NULL)
    return(allFiles()$datapath)
  })
  
  
  ###Creates a summary input table
  #Header for the input file summary table
  output$tableHeader <- renderText("Summary table of input files")
  
  #Creates a summary data.frame as a reactive object
  table <- reactive({

    #Shows the table headings before files are input
    if (is.null(allFiles())) {
      
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
    
    #Iterates through all the selected files in the data.frame 
    #to extract information from them
    for (i in 1:nrow(allFiles())) {
      
      #The filename of the file currently being extracted from
      filename <- UserFile_Name()[i]
      
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
      actualData <- read.csv(UserFile_Path()[i], header=TRUE)
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

  
  ###Runs the selected process
  #Shows the "Run process" button after the data are uploaded
  output$ui.runProcess <- renderUI({
    if (is.null(allFiles())) return()
      actionButton("runProcess", "Run process")
  })
  
  #Runs the selected process by calling on the QC script that Erik Leppo wrote
  observeEvent(input$runProcess, {

    #Moves the user-selected input files from the default upload folder to Shiny's working directory
    copy.from <- file.path(UserFile_Path())
    copy.to <- file.path(getwd(), UserFile_Name())
    file.copy(copy.from, copy.to)

    #Converts the more user-friendly input operation name to the name
    #that ContDataQC() understands
    operation <- renameOperation(input$Operation)
    
    # #Renames the input and output folder objects
    # inputFolder <- input$inputDir
    # outputFolder <- input$outputDir
    
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

        #Creates a vector of filenames
        fileNameVector <-  as.vector(UserFile_Name())
        
        #Changes the status bar to say that aggregation is occurring
        incProgress(0, detail = paste("Aggregating files"))
        
        #Saves the R console output of ContDataQC()
        consoleRow <- capture.output(
          
                        #Runs aggregation part of ContDataQC() on the input files
                        ContDataQC(operation, 
                        # fun.myDir.import = inputFolder,
                        # fun.myDir.export = outputFolder,
                        fun.myDir.import = getwd(),
                        fun.myDir.export = getwd(),
                        fun.myFile = fileNameVector,
                        fun.myReport.format = "html"
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
        colnames(console$disp) <- c("R console messages for all input files:")
        
      }
      
      #The QCRaw and Summarize functions can be fed individual input files
      #in order to have the progress bar incremement after each one is processed
      else {

        #Iterates through all the selected files in the data.frame 
        #to perform the QC script on them individually
        for (i in 1:nrow(allFiles())) {

          #Extracts the name of the file from the selected input file
          fileName <- UserFile_Name()[i]
          
          #Changes the status bar to say that the process is occurring
          incProgress(0, detail = paste("Operating on", fileName))

          #Saves the R console output of ContDataQC()
          consoleRow <- capture.output(
            
                          #Runs ContDataQC() on an individual file
                          ContDataQC(operation,
                          # fun.myDir.import = inputFolder,
                          # fun.myDir.export = outputFolder,
                          fun.myDir.import = getwd(),
                          fun.myDir.export = getwd(),
                          fun.myFile = fileName,
                          fun.myReport.format = "html"
                          )
          )

          #Appends the R console output generated from that input file to the 
          #console output data.frame
          consoleRow <- data.frame(consoleRow)
          console$disp <- rbind(console$disp, consoleRow)
          
          #Fills in the progress bar once the operation is complete
          incProgress(1/nrow(allFiles()), detail = paste("Finished", fileName))
          
          #Pauses the progress bar once it's done
          Sys.sleep(2)
          
        }
        
        #Names the single column of the R console output data.frame
        colnames(console$disp) <- c("R console output for all input files:")

      }

    })
    
  })
 
  ###Downloads the output data and deletes the created files
  #Shows the "Download" button after the selected process is run
  output$ui.downloadData <- renderUI({
    if (is.null(console$disp)) return()
    downloadButton("downloadData", "Download")
  })
  
  #Zips the output files and makes them accessible for downloading by the user
  observe({
    
    #Converts the more user-friendly input operation name to the name
    #that ContDataQC() understands
    operation <- renameOperation(input$Operation)
    
    #Formats the download timestamp for the zip file
    operationTime <- timeFormatter(Sys.time())
    
    #Zipping procedures for the output of the QC process
    if (operation == "QCRaw"){
      
      output$downloadData <- downloadHandler(
        
        #Names the zip file
        filename <- function() {
          paste(operation, operationTime, "zip", sep=".")
        },
        
        #Zips the output files
        content <- function(fname) {
  
          #Lists only the csv and html files on the server
          zip.csv <- dir(getwd(), full.names=TRUE, pattern="QC.*csv")
          zip.html <- dir(getwd(), full.names=TRUE, pattern="QC.*html")
          zip.log <- dir(getwd(), full.names=TRUE, pattern=".*tab")
          files2zip <- c(zip.csv, zip.html, zip.log)
          
          #Zips the files
          zip(zipfile = fname, files = files2zip)
        }
        ,contentType = "application/zip"
      )
    }
    
    #Zipping procedures for the output of the aggregation process
    if (operation == "Aggregate"){
      
      output$downloadData <- downloadHandler(
        
        #Names the zip file
        filename <- function() {
          paste(operation, operationTime, "zip", sep=".")
        },
        
        #Zips the output files
        content <- function(fname) {
          
          #Lists only the csv and docx files on the server
          zip.csv <- dir(getwd(), full.names=TRUE, pattern="DATA.*csv")
          zip.docx <- dir(getwd(), full.names=TRUE, pattern=".*docx")
          zip.log <- dir(getwd(), full.names=TRUE, pattern=".*tab")
          files2zip <- c(zip.csv, zip.docx, zip.log)
          
          #Zips the files
          zip(zipfile = fname, files = files2zip)
        }
        ,contentType = "application/zip"
      )
    }
    
    #Zipping procedures for the output of the SummaryStats process
    if (operation == "SummaryStats"){
      
      output$downloadData <- downloadHandler(
        
        #Names the zip file
        filename <- function() {
          paste(operation, operationTime, "zip", sep=".")
        },
        
        #Zips the output files
        content <- function(fname) {
          
          #Lists only the csv and docx files on the server
          zip.csv_DV <- dir(getwd(), full.names=TRUE, pattern="DV.*csv")
          zip.csv_STATS <- dir(getwd(), full.names=TRUE, pattern="STATS.*csv")
          zip.pdf <- dir(getwd(), full.names=TRUE, pattern=".*pdf")
          zip.log <- dir(getwd(), full.names=TRUE, pattern=".*tab")
          files2zip <- c(zip.csv_DV, zip.csv_STATS, zip.pdf, zip.log)
          
          #Zips the files
          zip(zipfile = fname, files = files2zip)
        }
        ,contentType = "application/zip"
      )
    }
    
    #Deletes the input and output files to keep the server from getting clogged
    deleteFiles(getwd(), UserFile_Name())
  
  })
  

  # #Removes the QC files from the server after the Shiny session ends 
  # #Not activating because it's not necessary now; the above deletion code works fine
  # #modified from https://groups.google.com/forum/#!topic/shiny-discuss/2WSKDO3Rljo
  # session$onSessionEnded(function(){
  # 
  #   deleteFiles(getwd(), UserFile_Name())
  #   
  # })
  
  
  ###Shows the R console output text
  #Shows the output notes from ContDataQC from the R console in R Shiny
  console <- reactiveValues()
  
  #Before running tool, shows a message saying that console output will be displayed
  output$logTextMessage <- renderText({
    
    if (is.null(console$disp)){
      
      beforeRun <- paste("Check here after running process for script messages...")
        return(beforeRun)
    }
  })
  
  #Shows the output notes from ContDataQC from the R console
  output$logText <- renderTable({

    if (is.null(input$selectedFiles))
      return(NULL)

    return(console$disp)
  })
  

  ###Shows all files on the server
  #For debugging only: shows the files on the server
  onServerTable <- reactive({
    onServerTableOutput <- as.matrix(list.files(getwd(), full.names = FALSE))
    colnames(onServerTableOutput) <- c("Files currently on server")
    return(onServerTableOutput)
  })
  
  output$serverTable <- renderTable({
    onServerTable()
  })
  

  #FOR TESTING. 
  output$testText <- renderText({
    
    inFile <- input$selectedFiles
    if (is.null(inFile))
      return(NULL)
    
    paste("This is for testing:", getwd())
  })
  
}
)
