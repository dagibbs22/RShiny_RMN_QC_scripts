shinyUI(navbarPage("Continuous data QC summary and statistics",
                    
  tabPanel("Tool background and data template",
           h3("Instructions"),
           p("This is where you can download a template continuous data csv file.")
  ),
           
  tabPanel("Tool interface",

    # Sidebar with inputs for app
    sidebarLayout(
      sidebarPanel(
  
        #The selected input file
        #Tool tip code from https://stackoverflow.com/questions/16449252/tooltip-on-shiny-r
        tags$div(title="Select one or more csv files to upload here",
                    
                 #Only allows csv files to be imported
                 fileInput("selectedFiles",label="Choose files", multiple = TRUE, accept = ".csv")
        )
        
        #Operation to be performed on the selected data
        ,selectInput("Operation", 
                    label = "Choose operation to perform",
                    choices = c("Get gage data", 
                                "QC raw data", 
                                "Aggregate QC'ed data", 
                                "Summary statistics"),
                    selected = "QC raw data")
  
        #Not currently using
        #,helpText("HelpText",label="Help Text")
        
        # #User types or copies in the full output directory
        # ,textInput("inputDir", label="Input directory for data", value = "", width = NULL, placeholder = NULL)
        
        #User types or copies in the full output directory
        ,textInput("outputDir", label="Output directory for data", value = "", width = NULL, placeholder = NULL)
  
        #Runs the selected process
        ,tags$div(title="Click to run selected operation",
                  actionButton("runProcess",label='Run operation')
        )
        
      ),
      
      mainPanel(
  
        #Header for the summary table
        h4(textOutput("tableHeader")),
        
        # #FOR TESTING ONLY. Outputs testing text
        textOutput(paste("testText")),
        # textOutput(paste("DirServer")),
        
        #Shows an empty table until files are input
        tableOutput("nullTable"),
        
        #Outputs the table with properties of the input spreadsheets,
        #and a testing table of the beginning of the spreadsheets
        tableOutput("summaryTable")
      )
    )
  ),
  
  tabPanel("R console output",
           p("This page shows text output by the tool."),
           p("Check this once the tool has finished."),
           tableOutput("logText")
  )
  
)
)