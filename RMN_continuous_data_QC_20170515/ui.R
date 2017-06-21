shinyUI(fluidPage(
  
  # Application title
  titlePanel("Continuous Data: QC and Summary Statistics"),
  
  # Sidebar with inputs for app
  sidebarLayout(
    sidebarPanel(

      #The selected input file
      #Tool tip code from https://stackoverflow.com/questions/16449252/tooltip-on-shiny-r
      tags$div(title="Select one or more files to upload here",
                  fileInput("selectedFiles",label="Choose files", multiple = TRUE)
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
      
      #User types or copies in the full output directory
      ,textInput("inputDir", label="Input directory for data", value = "", width = NULL, placeholder = NULL)
      
      #User types or copies in the full output directory
      ,textInput("outputDir", label="Output directory for data", value = "", width = NULL, placeholder = NULL)

      #Runs the selected process
      ,tags$div(title="Click to run selected operation",
                actionButton("runProcess",label='Run operation')
      )
      
    ),
    
    mainPanel(

      #FOR TESTING ONLY. Outputs testing text
      #textOutput("testText")

      #Outputs the table with properties of the input spreadsheets,
      #and a testing table of the beginning of the spreadsheets
      tableOutput("summaryTable")
      # ,tableOutput("contents")
    )
  )
))
