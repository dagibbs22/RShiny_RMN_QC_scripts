shinyUI(
 
  navbarPage("Continuous data QC summary and statistics",
                    
  tabPanel("Tool background and data template",
           
           fluidRow(
             column(5,
                    h3("Background", align = "center"),
                    br(),
                    p("The Regional Monitoring Networks (RMNs) are networks of long-term stream monitoring sites. 
                      They are a partnership between the U.S. EPA and states, tribes, and other local organizations.
                      Their goal is to establish a baseline for stream temperature, hydrology, and macroinvertebrate communities
                      in streams across the US and characterize natural variation and long-term trends. Although the types of 
                      sites included in the RMNs vary throughout the U.S., many of the sites are high-quality, high-gradient 
                      reference sites."),
                    br(),
                    p("All RMN sites use the same continuous temperature and hydrology measurement protocols. This website
                      allows RMN partners to QC their continuous stream data in a standard way. It accepts air and water temperature
                      and pressure, water level, and stream flow."),
                    br(),
                    p("For more information on the RMNs, please refer to: https://cfpub.epa.gov/ncea/global/recordisplay.cfm?deid=307973.
                      If you have questions, please contact bierwagen.britta@epa.gov or gibbs.david@epa.gov.")
             ),
             
             column(5, offset = 1,
                    h3("Directions", align = "center"),
                    br(),
                    p("In order for this QC website to correctly process your continuous data, you need it formatted 
                      in a specific way. Download a template of the csv to use for this below. The template has a few sample rows 
                      of data in it; delete these and replace them with your own, making sure you use the same formats.
                      Be very careful to format the dates correctly; the QC process is very particular about date formats."),
                    downloadButton("downloadTemplate","Download continuous data template")
             )
           )
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
        
        ,downloadButton("downloadData", label = "Download")
        
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
           p("This tab shows messages output by the tool. If there are any errors when the tool runs, please copy
             the messages and send them and the files you tried inputting to the contacts listed on the intro tab."),
           tableOutput("logText"),
           br(),
           br(),
           br(),
           textOutput("logTextMessage")
  )
  
)
)