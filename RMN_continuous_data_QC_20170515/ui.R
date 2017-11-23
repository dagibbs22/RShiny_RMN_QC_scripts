shinyUI(
 
  navbarPage("Continuous data QC, summary, and statistics- PRELIMINARY WEBSITE",
                   
  tabPanel("Tool background and data template",
           
           fluidRow(
             column(5,
                    h3("Background", align = "center"),
                    br(),
                    p("The Regional Monitoring Networks (RMNs) are groups of long-term stream monitoring sites designed 
                      to detect changes in stream health over large areas and long time periods. 
                      Their goal is to establish a baseline for stream temperature, hydrology, and macroinvertebrate communities
                      in streams across the US and characterize natural variation and long-term trends.
                      They are a partnership between the U.S. EPA, other federal agencies, states, tribes, 
                      and other local organizations.
                      Although the types of sites included in the RMNs vary throughout the U.S., many of the sites are 
                      high-quality, high-gradient reference sites."),
                    p("For more information on the RMNs, please refer to ", 
                      tags$a(href="https://cfpub.epa.gov/ncea/global/recordisplay.cfm?deid=307973", "the RMN report.", target="_blank")),
                    br(),
                    p("One component of the RMN program is the use of standardized methods across sites to
                      improve statistical power in detecting regional changes in streams.
                      To this end, the same protocols are being used across RMN sites to collect automated 
                      water temperature measurements at 15 or 30 minute intervals (continuous data). 
                      Some sites also collect water level or flow measurements at the same intervals."),
                    br(),          
                    p("This website performs three operations on your continuous stream data,
                      as well as helping users download data from USGS gages.
                      Collectively, these operations allow all RMN partners to QC and summarize their continuous stream data in 
                      a standardized way without having to download any programs to their computer."),
                    p("1. QC raw data. 
                      Using this website, all RMN partners can QC their continuous stream data in a standardized way without having
                      to download any programs to their computer.  
                      It accepts air and water temperature and pressure, sensor depth, and stream flow measurements. 
                      It performs four checks on each input parameter: unrealistic values, spikes, fast rates of change, and flat values.
                      Although it performs QC checks on the data you input data, it is up to you to decide how to respond to any erroneous 
                      or suspect values. 
                      Each value can pass, be flagged as suspect (S), or be flagged as failing (F)."),
                    p("2. Aggregate QCed data by date or by data type. 
                      By date: It can combine separate QCed temperature spreadsheets from the same site with the same
                      parameters covering different time periods (e.g., combine 2/8/14-4/15/14 and 4/16/14-7/17/14 into a single 
                      spreadsheet covering 2/8/14-7/7/14). 
                      By parameter: It can combine QCed spreadsheets with different parameters from the same time period at the same site 
                      into a multi-parameter spreadsheet (e.g., separate air and water temperature spreadsheets from 7/1/15 to 9/30/15 
                      into an air-water spreadsheet over that same time period)."),
                    p("3. Produce summary statistics and plots of QCed data. 
                      It summarizes data by day, month, season, year, mean,
                      exceedance, and more."),
                    p("4. Download USGS gage data. You can input USGS gage IDs and a date range and the website will 
                      download a separate csv for each gage over that time period. 
                      See the 'Download USGS gage data' tab for more information."),
                    br(),
                    p("If you have questions about the RMNs or this tool, please contact bierwagen.britta@epa.gov or gibbs.david@epa.gov.
                      The R code underlying the data processing (package ContDataQC) was written by Erik Leppo at Tetra Tech, Inc. 
                      The package is available for download from GitHub for running on your computer within R 
                      (repo 'leppott/ContDataQC')."),
                    br(),
                    p(paste("NOTE: This website is under development. New versions will be released periodically. 
                      E-mail the above contacts to find out if there is a new version available at a different link. 
                      This version was last updated on "), Sys.Date())
                    
             ),
             
             column(5, offset = 1,
                    h3("Instructions for running the QC process", align = "center"),
                    br(),
                    p("1. Convert all the spreadsheets you will upload to this website into csvs."),
                    p("2. Name your input files as follows: SITENAME_DATATYPE_STARTDATE_ENDDATE.csv. The site name
                      should match the site name in the input files. Data types are as follows: A (air), W (water), G (flow), 
                      AW, AG, WG, and AWG. Start and end dates should match the dates in the input files and have the format
                      YYYYMMDD (e.g., 20151203). Some example input file names are: 097_A_20150305_20150630.csv, 
                      GOG12F_AW_20130426_20130725.csv, and BE92_AWG_20150304_20151231.csv."),
                    p("3.	Download the template using the “Download continuous data template” button on the 
                      “Tool background and data template” tab of the website. In order for this website to 
                      correctly process your continuous data, you need to format it in a specific way."),
                    downloadButton("downloadTemplate","Download continuous data template"),
                    br(),
                    br(),
                    p("4. Copy the appropriate column headers from the template into the spreadsheets you want 
                      the website to process. The only required fields to run the QC process are date-time, station ID, 
                      and at least one measurement column (air, water, sensor depth, or flow). It does not matter what
                      order the columns are in within your spreadsheets."),
                    p("5. Verify that the data in your spreadsheets are in the same formats as the data in 
                      the template spreadsheet (e.g., that the values in 'Date Time' are formatted the same
                      as in the template). The website will not work on your data if the formats are 
                      incorrect."),
                    p("6. Delete any extraneous columns from your spreadsheets."),
                    p("7. Delete any extra header rows besides the ones with the field names. Delete any rows at 
                      the bottom of the spreadsheets that show termination of the log."),
                    p("8. Upload your files to the website using the 'Browse' button on the next tab. Once the
                      files are uploaded, a 'Run process' button should appear below the upload box."),
                    p("Make sure that the 'QC raw data' option is selected in the 'Choose operation to perform'
                      drop-down on the next tab."),
                    p("10. Verify that the files are being interpreted correctly in the table."),
                    p("11. Click the 'Run process' button on the next tab. A progress bar will appear in the
                      bottom-right of the tab. It will advance as each file is completed. Thus, if you 
                      upload three files, it will wait at 0%, jump to 33%, jump to 66%, and then jump to 100%."),
                    p("12. Once the process is completed, a 'Download' button will appear below the 'Run process'
                      button. Click the button to download a zip file of all output files (spreadsheets and QC
                      reports). Where the files will download on your computer depends on the configuration 
                      of your internet browser."),
                    br(),
                    br(),
                    p("For more information on the input file requirements, please visit the RMN Sharepoint or ftp sites.")
             )
           )
  ),
           
  tabPanel("QC tool interface",

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
                    choices = c("",
                                "QC raw data", 
                                "Aggregate QC'ed data", 
                                "Summary statistics")
                    ,selected = "")

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
        tableOutput("nullTable1"),
        tableOutput("nullTable2"),
        
        #Outputs the table with properties of the input spreadsheets,
        #and a testing table of the beginning of the spreadsheets
        tableOutput("summaryTable1"),
        tableOutput("summaryTable2"),
        
        br(),
        br(),
        br(),
        
        #Shows a note if spreadsheets with multiple sites are selected
        #for the Aggregate process
        h4(textOutput("moreThanOneSite"))
      )
    )
  ),
  
  tabPanel("Download USGS gage data",
           fluidRow(
             column(5, 
                h3("Instructions", align = "Center"),
                br(),
                p("You can download data from USGS gages on this tab."),
                br(),
                p("1. Enter as many USGS station IDs as you like separated by 
                  commas and spaces (e.g., 01187300, 01493000, 01639500)."),
                p("2. Enter a starting and ending date for which data will
                  be retrieved for each station; the same date range
                  will be used for every station."),
                p("3. Click the 'Retrieve USGS data' button. 
                  A progress bar will appear in the bottom-right of the tab. 
                  It will advance as each file is completed. 
                  Thus, if you select three stations, it will wait at 0%, 
                  jump to 33%, jump to 66%, and then jump to 100%."),
                p("4. After data retrieval completes, a download button 
                  will appear. Click the button to download a zip file of all station records.
                  Where the files will download on your computer depends on the configuration 
                  of your internet browser.")
             ),
             
             column(5, offset = 1,
                h3("Download USGS gage data here")
                ,br()
                ,textInput("USGSsite", "USGS site ID(s) (separated by commas and spaces)")
                ,textInput("startDate", "Starting date (YYYY-MM-DD)")
                ,textInput("endDate", "Ending date (YYYY-MM-DD)")
                ,br()
                ,actionButton("getUSGSData", "Retrieve USGS data")
                ,br()
                ,br()
                    
                #Only shows the "Download" button after the process has run
                ,tags$div(title="Click to download your USGS gage data",
                    uiOutput('ui.downloadUSGSData'))      
             )
           )
  ),
  
  tabPanel("R console output",
           p("This tab shows messages output by the QC, aggregating, summarizing, and USGS data retrieval processes. 
             If there are any errors when the tool runs, please copy
             the messages and send them and your input files to the contacts listed on the tool background tab."),
           tableOutput("logText"),
           tableOutput("logTextUSGS"),
           tags$b(textOutput("logTextMessage"))

           ## For debugging only: lists all files on the server
           # ,br()
           # ,br()
           # ,br()
           # ,br()
           # ,tableOutput("serverTable")
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
           ,p("Q: I've gotta QC my data on the go. Can I use this site on my phone?")
           ,p("A: Mobile use of this app is untested. Please let us know how it goes.")
  )
  
)
)