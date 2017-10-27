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
                      and pressure, water level, and stream flow measurements. This website performs QC checks on the input data but
                      it is up to the user to decide how to respond to any wrong or suspect values. In addition to running data
                      through QC checks, this app can also combine multiple QCed spreadsheets from different time periods at individual
                      sites (e.g., air/water temperature spreadsheets from 2/8/14-4/15/14 and 4/16/14-7/17/14) and combine QCed 
                      spreadsheets with different parameters from the same time period at the same site (e.g.,
                      separate air and water temperature spreadsheets from 7/1/15 to 9/30/15). Finally, this app creates reports on and 
                      graphs of annual, seasonal, monthly, and daily variation in the input parameters."),
                    br(),
                    p("For more information on the RMNs, please refer to ", 
                      tags$a(href="https://cfpub.epa.gov/ncea/global/recordisplay.cfm?deid=307973", "the RMN report.", target="_blank")),
                    p("If you have questions about the RMNS or this tool, please contact bierwagen.britta@epa.gov or gibbs.david@epa.gov.")
                    
             ),
             
             column(5, offset = 1,
                    h3("Directions", align = "center"),
                    br(),
                    p("In order for this QC website to correctly process your continuous data, you need it formatted 
                      in a specific way. Download a template csv below to help with this. The template has a few sample rows 
                      of data in it; delete these and replace them with your own, making sure you use the same formats.
                      Be very careful to format the dates correctly; the QC process is very particular about date formats."),
                    downloadButton("downloadTemplate","Download continuous data template"),
                    br(),
                    br(),
                    p("Input files should be named as follows: SITENAME_DATATYPE_STARTDATE_ENDDATE.csv. The site name
                      should match the site name in the input files. Data types are as follows: A (air), W (water), G (flow gage), 
                      AW, AG, WG, and AWG. Start and end dates should match the dates in the input files and have the format
                      YYYYMMDD (e.g., 20151203). Some example input file names are: 097_A_20150305_20150630.csv, 
                      GOG12F_AW_20130426_20130725.csv, and BE92_AWG_20150304_20151231.csv."),
                    p("For more information on the input file requirements, please visit the RMN Sharepoint or ftp sites."),
                    br(),
                    p("Once you have your data in the correct format, proceed to the next tab to upload your files, process them,
                      and download them.")
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
                    choices = c( 
                               #"Get gage data", 
                                "QC raw data", 
                                "Aggregate QC'ed data", 
                                "Summary statistics"),
                    selected = "QC raw data")

        # #User types or copies in the full output directory
        # ,textInput("inputDir", label="Input directory for data", value = "", width = NULL, placeholder = NULL)
        
        # #User types or copies in the full output directory
        # ,textInput("outputDir", label="Output directory for data", value = "", width = NULL, placeholder = NULL)
  
        #Only shows the "Run process" button after data are uploaded
        ,tags$div(title="Click to run selected operation",
                  uiOutput('ui.runProcess')
        )
        ,br()
        ,br()
         
        #Only shows the "Download" button after the process has run
        ,tags$div(title="Click to download your data",
                  uiOutput('ui.downloadData')
        )
      ),
      
      mainPanel(
  
        #Header for the summary table
        h4(textOutput("tableHeader")),
        
        p("After uploading data and selecting your process, confirm that the table below is showing
          the expected values"),
        
        # #FOR TESTING ONLY. Outputs testing text
        # textOutput(paste("testText")),

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
             the messages and send them and your input files to the contacts listed on the tool background tab."),
           tableOutput("logText"),
           tags$b(textOutput("logTextMessage"))

           ##For debugging only: lists all files on the server
           ,br()
           ,br()
           ,br()
           ,br()
           ,tableOutput("serverTable")
  ),
  
  tabPanel("FAQ",
           h2("A growing list of frequently asked questions")
           ,br()
           ,p("Question: Why isn't my spreadsheet processing? The website just shuts down.")
           ,p("Answer: One common reason the site won't process input spreadsheets is because they are
             formatted incorrectly. Make sure the formatting of your input spreadsheets is correct by
             checking it against the template on the 'Tool background and data template' tab. If that
             does not fix the problem, contact the e-mail addresses listed on that tab.")
           ,br()
           ,p("Q: What happens if the site IDs in the input file names don't match the site IDs in the 
             input files?")
           ,p("A: The tool will still work. The output file names will use the site IDs in the input
             file names. The site IDs in the output files will use the site IDs used in the input
             files. Nevertheless, it is good practice to have the site IDs in the file names and
             inside the files match.")
           ,br()
           ,p("Q: What happens if the date ranges in the input file names don't match the date ranges 
             in the files?")
           ,p("A: The tool will still process the inputs over the date ranges used inside the 
             files (i.e. the dates of the first and last rows of each input file). The output file
             names will use the date ranges of the input file names. It is good practice to have 
             the date ranges in the file names and inside the files match.")
           ,br()
           ,p("Q: What internet browsers is this compatible with?")
           ,p("A: It has been tested with Internet Explorer and Google Chrome. It may be compatible
              with other browsers but they have not been tested.")
           ,br()
           ,p("Q: I started the QC step and then left my computer for 10 minutes. When I returned
              the website was grayed out. What happened?")
           ,p("A: The website times out after a few minutes of not being used. Of the QC, aggregate,
              and summarize processes, QCing takes the longest and it should never take more than
              a minute or two per file.")
           ,br()
           ,p("Q: Can other people download my files from the website?")
           ,p("A: They should not be able to. As soon as you upload a new set of data or close the 
              tab the website is in, your old data should be deleted. If you do somehow get someone
              else's data (instead of or in addition to yours), please contact us.")
           ,br()
           ,p("Q: Why does the progress bar stay still for awhile then jump ahead to completion?")
           ,p("A: It has to do with how the file processing is done. The progress bar does not 
              move until after each file is completed. Thus, if only one file is uploaded, the 
              progress bar goes from 0% to 100% in one jump. If three files are uploaded, the bar
              jumps from 0% to 33% to 66% to 100%.")
           ,br()
           ,p("Q: What will happen if I accidentally run the wrong process on my input files?")
           ,p("A: Either the tool won't run at all or it'll produce output files with weird names
              (e.g., if you run the QC process on files you've already QCed, you'll get output
              files that start with the name 'QC-QC_'")
           ,br()
           ,p("Q: I've gotta QC data on the go. Can I use this site on my phone?")
           ,p("A: Mobile use of this app is untested. Please let us know how it goes.")
  )
  
)
)