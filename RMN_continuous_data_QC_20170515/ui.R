shinyUI(fluidPage(
  
  # Application title
  titlePanel("Continuous Data: QC and Summary Statistics"),
  
  # Sidebar with inputs for app
  sidebarLayout(
    sidebarPanel(

      #The selected input file
      fileInput("selectedFiles",label="Choose files", multiple = TRUE)
      
      #Operation to be performed on the selected data
      ,selectInput("Operation", 
                  label = "Choose operation to perform",
                  choices = c("GetGageData", "QCRaw", "Aggregate", "SummaryStats"),
                  selected = "QCRaw")

      #Not currently using
      #,helpText("HelpText",label="Help Text")
      
      #User types or copies in the full output directory
      ,textInput("inputDir", label="Input directory for data", value = "", width = NULL, placeholder = NULL)
      
      #User types or copies in the full output directory
      ,textInput("outputDir", label="Output directory for data", value = "", width = NULL, placeholder = NULL)

      #Runs the selected process
      ,actionButton("runProcess",label='Run Operation')
      
    ),
    
    mainPanel(

      #FOR TESTING ONLY. Outputs testing text
      textOutput("testText")

      #Outputs the table with properties of the input spreadsheets,
      #and a testing table of the beginning of the spreadsheets
      ,tableOutput("summaryTable")
      # ,tableOutput("contents")
    )
  )
))
