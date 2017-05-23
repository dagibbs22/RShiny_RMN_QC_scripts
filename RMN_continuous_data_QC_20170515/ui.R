
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

      #Input for the name of the field in the input spreadsheets containing the date
       textInput("dateField",
                 label="Field with date-time values (must not have spaces)",
                 value = "",
                 placeholder = NULL)
      
       #Input for the name of the field in the input spreadsheets containing the station ID
      ,textInput("stationIDField",
                 label="Field with station ID values",
                 value = "",
                 placeholder = NULL)
      
      #The selected input file
      ,fileInput("file1",label="Choose File", multiple = TRUE)
      
      #Operation to be performed on the selected data
      ,selectInput("Operation", 
                  label = "Choose operation to perform",
                  choices = c("GetGageData", "QCRaw", "Aggregate", "SummaryStats"),
                  selected = "QCRaw")

      #Type of data to be operated on
      ,selectInput("DataType", 
                    label = "Choose a type of data file",
                    choices = c("Air","Water","AW","Gage","AWG","AG","WG" ),
                    selected = "AW")

      #The starting and ending dates for the process.
      #Initially populated by the first and last dates in the spreadsheet
      #but can be modified by the user
      ,uiOutput("dates")
      
      #Not currently using
      # ,dateRangeInput('dateRange',
      #                 label = 'Date range input: yyyy-mm-dd',
      #                 start = Sys.Date() - 2, end = Sys.Date() + 2
      # )
      
      #       selectInput("DirImport", 
      #                   label = "Choose import directory for data (can be set by operation)",
      #                   choices = c("Data1_RAW","Data2_QC","Data3_Aggregated","Data4_Stats" ),
      #                   selected = "Olsen Model Background"),
      #       
      #       selectInput("DirExport", 
      #                   label = "Choose export directory for data (can be set by operation)",
      #                   choices = c("Data1_RAW","Data2_QC","Data3_Aggregated","Data4_Stats" ),
      #                   selected = "Olsen Model Background"),
      
      #Not currently using
      #,helpText("HelpText",label="Help Text")
      
      #Not currently using
      ,textInput("BaseDir", label="Base directory for data.", value = "", width = NULL, placeholder = NULL)
      
      #Runs the process
      ,actionButton('runProcess',label='Run Operation')
      
    ),##sidebarpanel.END
    

    mainPanel(
      # 
      # h4("output$dir"),
      # verbatimTextOutput("dir"), br(),
      # h4("Files in that dir"),
      # verbatimTextOutput("files")
      
      #DT::dataTableOutput("table"),
      
      #Outputs the testing text, the table with properties of the input spreadsheets,
      #and a testing table of the beginning of the spreadsheets
      textOutput("file")
      ,tableOutput("summaryTable")
      ,tableOutput("contents")
    )
  )##sidebarlayout.END
))
