
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Continuous Data, QC and Summary Statistics"),
  
  # Sidebar with inputs for app
  sidebarLayout(
    sidebarPanel(

      #The selected input file
      fileInput("file1",label="Choose File", multiple = TRUE)
      
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

      #FOR TESTING
      ,textInput("val1", label="First value")
      ,textInput("val2", label="Second value")
      
      #Runs the selected process
      ,actionButton("runProcess",label='Run Operation')
      
    ),##sidebarpanel.END 
    

    mainPanel(

      #FOR TESTING ONLY. Outputs testing text and some other testing outout
      textOutput("file")
      ,tableOutput("df_data2_out")
      
      #Outputs the table with properties of the input spreadsheets,
      #and a testing table of the beginning of the spreadsheets
      ,tableOutput("summaryTable")
      ,tableOutput("contents")
    )
  )##sidebarlayout.END
))
