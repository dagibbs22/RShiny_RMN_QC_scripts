shinyUI(

  navbarPage("Continuous data QC, summary, and statistics- PRELIMINARY WEBSITE",
             theme= shinytheme("spacelab"), #also liked "cerulean" at https://rstudio.github.io/shinythemes/
                   
  tabPanel("Site introduction",
                    h3("Site background and features", align = "center"),
                    br(),
                    p("The Regional Monitoring Networks (RMNs) are groups of long-term stream monitoring sites designed
                      to detect changes in stream health over large areas and long time periods.
                      Their goal is to establish a baseline for stream temperature, hydrology, and macroinvertebrate communities
                      in streams across the US and characterize natural variation and long-term trends.
                      They are a partnership between the U.S. EPA, other federal agencies, states, tribes,
                      and local organizations.
                      Although the types of sites included in the RMNs vary throughout the U.S., many of the sites are
                      high-quality, high-gradient reference sites. For more information on the RMNs, please refer to the ",
                      tags$a(href="https://cfpub.epa.gov/ncea/global/recordisplay.cfm?deid=307973", "RMN report.", target="_blank")),
                    br(),
                    p("One component of the RMN program is the use of standardized monitoring methods across sites to
                      improve characterization of baseline conditions and the statistical power to detect 
                      regional, long-term changes in streams.
                      To this end, the same protocols are being used across RMN sites to collect automated 
                      water temperature measurements at 15 or 30 minute intervals (continuous data). 
                      Some sites also collect water level or flow measurements at the same intervals.
                      One aspect of using standardized protocols is using the same quality control (QC) checks on data collected
                      at all sites."),
                    br(),          
                    p("This website performs three operations on continuous stream data,
                      as well as helping users download data from USGS gages.
                      Collectively, these operations allow all RMN partners to QC and summarize their continuous stream data in 
                      a standardized way without having to download any programs to their computer.
                      Although this website was developed for RMNs, non-RMN monitoring programs can use this website
                      on their data, too."),
                    br(),
                    p("The features of this website are:"),
                    tags$b("1. QC raw data."), 
                    p("Using this website, all RMN partners can perform quality control checks on their continuous stream data 
                      in a standardized way without having to download any programs to their computer.  
                      This website accepts air and water temperature and pressure, sensor depth, and stream flow measurements.
                      You can process files from multiple sites at the same time but the more records you submit, the longer
                      it will take for the website to process them.
                      It performs four checks on each input parameter: unrealistic high/low values, spikes, fast rates of change, 
                      and values staying flat (not changing). 
                      Each value can pass (P), be flagged as suspect (S), or be flagged as failing (F).
                      Whether each value is marked as P, S, or F (or X if the test is not applicable) depends on the input threshold
                      values for the QC tests.
                      A spreadsheet with default threshold values can be found in the 'Advanced features' tab. 
                      You can also upload your own custom threshold spreadsheet on that tab.
                      Although this website performs QC checks on the data you input, 
                      it is up to you to decide how to respond to any erroneous or suspect values. 
                      The website does not change your values for you."),
                    tags$b("2. Aggregate QCed data."),
                    p("This website can combine spreadsheets that have been through the QC process in two different ways:
                      by date or by data type. 
                      By date: This website can combine multiple QCed spreadsheets from the same site with the same
                      parameters covering different time periods (e.g., combine 2/8/14-4/15/14 and 4/16/14-7/17/14 into a single 
                      spreadsheet covering 2/8/14-7/17/14). 
                      By parameter: This website can combine multiple QCed spreadsheets with different parameters from the same time period at the same site 
                      into a multi-parameter spreadsheet (e.g., separate air and water temperature spreadsheets from 7/1/15 to 9/30/15 
                      into an air-water spreadsheet over that same time period)."),
                    tags$b("3. Produce summary statistics and plots of QCed data."), 
                    p("Each parameter input to this operation produces three summary output files. 
                      1. A spreadsheet with daily average values.
                      2. A spreadsheet with annual, seasonal, monthly, and daily averages, medians, minima, maxima, ranges, standard
                      deviations, and more.
                      3. A pdf with graphs by day, month, season, and year."),
                    tags$b("4. Download USGS gage data."),
                    p("You can input USGS gage IDs and a date range and the website will 
                      download a separate csv for each gage over that time period. 
                      See the 'Download USGS gage data' tab for more information."),
                    br(),
                    p("If you have questions about the RMNs or this website, please contact Britta Bierwagen (bierwagen.britta@epa.gov), 
                      David Gibbs (gibbs.david@epa.gov), or Jen Stamp (jen.stamp@tetratech.com).
                      You may also submit a bug/enhancement notice at this project's",
                      tags$a(href="https://github.com/dagibbs22/RShiny_RMN_QC_scripts/issues", "GitHub page.", target="_blank"),
                      "The R code underlying the data processing (package ContDataQC) was written by Erik Leppo at Tetra Tech, Inc. 
                      The package is available for download from GitHub for running on your computer within R 
                      (repo 'leppott/ContDataQC'). 
                      David Gibbs (ORISE fellow at the U.S. EPA) developed this website."),
                    br(),
                    p(paste("NOTE: This website is under development. New versions will be released periodically. 
                      E-mail the above contacts to find out if there is a new version available at a different link. 
                      This version was last updated on "), Sys.Date(), "."),
                    br()
                    
             
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

        #Only shows the "Run operation" button after data are uploaded
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
        
        tabsetPanel(type="tabs",
  
            tabPanel("Instructions",
                     h3("Instructions", align = "center"),
                     br(),
                     p("Below are abbreviated instructions for using the QC/aggregate/summarize features of this
                      website. 
                      For more complete information on managing continuous data, preparing data for this website,
                      understanding outputs, and troubleshooting, please refer to ",
                     a("this presentation. ", target="_blank", href="RMN_QC_website_slides_2018_02_14.pdf"),
                       "You can find some test files ",
                     a("here.", target="_blank", href="Continuous_data_test_files_2017_11_28.zip"),
                     p("1. Convert all the spreadsheets you will upload to this website into csvs."),
                     p("2. Name your input files as follows: SITENAME_DATATYPE_STARTDATE_ENDDATE.csv. The site name
                         should match the site name in the input files. Data types are as follows: A (air), W (water), G (flow), 
                         AW, AG, WG, and AWG. Start and end dates should match the dates in the input files and have the format
                         YYYYMMDD (e.g., 20151203). Some example input file names are: 097_A_20150305_20150630.csv, 
                         GOG12F_AW_20130426_20130725.csv, and BE92_AWG_20150304_20151231.csv."),
                     p("3. Download the continuous data ",
                     a("template. ", target = "_blank", href="continuous_data_template_2017_11_15.csv"),
                     "In order for this website to correctly process your continuous data, you need to format your data in a specific way."),
                     p("4. Copy the appropriate column headers from the template into the spreadsheet(s) you want 
                      the website to process. The only required fields to run the QC process are date-time, station ID, 
                      and at least one measurement column (air, water, sensor depth, or flow). It does not matter what
                      order the columns are in within your spreadsheet(s)."),
                     p("5. Verify that the data in your spreadsheets are in the same formats as the data in 
                      the template spreadsheet (e.g., that the values in 'Date Time' are formatted the same
                      as in the template). The website will not work on your data if the formats are 
                      incorrect."),
                     p("6. Delete any extraneous columns from your spreadsheets."),
                     p("7. Delete any extra header rows besides the ones with the field names. Delete any rows at 
                      the bottom of the spreadsheets that show termination of the sensor log."),
                     p("8. Upload your files to the website using the 'Browse' button to the left."),
                     p("9. Verify that the files are being interpreted correctly in the tables in the 'Summary tables' tab.
                      If they are not showing as expected, it means that something is wrong with your input file(s), e.g.,
                      the column headings are incorrect."),
                     p("10. Select which operation you want to perform on your spreadsheets using the drop-down menu to the left. 
                      A 'Run operation' button should appear below the operation selection dropd-down menu."),
                     p("11. Click the 'Run operation' button. 
                      A progress bar will appear in the bottom-right of the browser tab. 
                      It will advance after each file is processed. 
                      Thus, if you upload three files, it will wait at 0%, jump to 33%, jump to 66%, and then jump to 100%."),
                     p("12. Once the process is completed, a 'Download' button will appear below the 'Run operation'
                      button. Click the button to download a zip file of all output files (spreadsheets and QC
                      reports). Where the files will download on your computer depends on the configuration 
                      of your internet browser."),
                     br(),
                     br(),
                     p("For more information on the input file requirements, please visit the RMN Sharepoint or ftp sites."))
            ),
            
            tabPanel("Summary tables",
                     
              h3("Summary tables of input files", align = "center"),
              br(),

              p("After uploading data, confirm that the table below is showing
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
      
              #Shows a note if the user uploads non-QCed data and selects
              #the Aggregate or Summarize processes
              h4(textOutput("aggUnQCedData")),
              h4(textOutput("summUnQCedData")),
              
              #Shows a note if spreadsheets with multiple sites are selected
              #for the Aggregate process
              h4(textOutput("moreThanOneSite"))
           )
        )
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
  
  tabPanel("Advanced features",
           fluidRow(
             column(5, 
               h3("R console output", align = "Center"),
               p("This panel shows messages output by the QC, aggregating, summarizing, and USGS data retrieval processes. 
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
             
             column(5, offset = 1,
               h3("Custom QC thresholds", align = "Center"),
               p("You can upload custom QC thresholds here. 
                 Please use",
                 a("this ", target="_blank", href="Config_R.zip"),
                 "configuration document as a template."),
               p("Once you have made your changes to the configuration file, upload them below."),
               br(),
               #Tool tip code from https://stackoverflow.com/questions/16449252/tooltip-on-shiny-r
               tags$div(title="Select R configuration file to upload here",
                        
                        #Only allows R files to be imported
                        fileInput("configFile",label="Choose configuration file", multiple = FALSE, accept = ".R")
               )
               
               ,br()
               ,br()
               
               #Only shows the "Default configuration" button after a user-selected file has been used
               ,tags$div(title="Click to use default configuration data",
                         uiOutput('ui.defaultConfig')
               )
             )
           )
  ),
  
  tabPanel("FAQ",
           h3("A growing list of potentially frequently asked questions")
           ,br()
           ,p("Question: What internet browsers is this website compatible with?")
           ,p("Answer: It has been tested with Internet Explorer and Google Chrome. 
              It may be compatible with other browsers but they have not been tested.")
           ,br()
           ,p("Q: What will happen if the site IDs in the input file names don't match the site IDs in the 
              input files?")
           ,p("A: The tool will still work. The output file names will use the site IDs in the input
              file names. 
              The output spreadsheets themselves will use the site IDs used in the input spreadsheets. 
              Nevertheless, it is good practice to have the site IDs in the file names and inside 
              the files match.")
           ,br()
           ,p("Q: What will happen if the date ranges in the input file names don't match the date ranges 
              in the files?")
           ,p("A: The tool will still process the inputs over the date ranges used inside the 
              files (i.e. the dates of the first and last rows of each input file). 
              The output file names will use the date ranges of the input file names. 
              It is good practice to have the date ranges in the file names and inside the files match.")
           ,br()
           ,p("Q: What will happen if I try to aggregate files with overlapping dates?")
           ,p("A: This may cause errors in the output spreadsheet. 
              We recommend that the files input to the aggregate process do not have overlapping dates. 
              It is fine if the input files are non-consecutive (i.e. skip dates).")
           ,br()
           ,p("Q: What's the largest spreadsheet size I can upload?")
           ,p("A: The total size of uploaded spreadsheets should not be larger than 70 MB.
              Note that it would take the website quite a while to process such a large input 
              and the progress bar would show no progress until processing is complete.")
           ,br()
           ,p("Q: What's the limit on the number of spreadsheets I can upload?")
           ,p("A: No limit is known at this point. We have tested the website with seven spreadsheets.
              If you encounter a limit, please let us know.")
           ,br()
           ,p("Q: What will happen if I accidentally run the wrong process on my input files?")
           ,p("A: Either the tool won't run at all or it'll produce output files with weird names
              (e.g., if you run the QC process on files you've already run through the QC process, 
              you'll get output files that start with the name 'QC_QC_').")
           ,br()
           ,p("Q: How long does it take for the website to process uploaded files?")
           ,p("A: Of the QC, aggregate, and summarize processes, QCing takes the longest and it should 
              not take more than a minute or two per 5000 records being processed. 
              Retrieving USGS gage data should only take a few minutes per site for a year's worth
              of records.")
           ,br()
           ,p("Q: I ran one of the website's processes and then left my computer for 10 minutes. 
              When I returned the website was grayed out. What happened?")
           ,p("A: The website times out after a few minutes of not being used. 
              You will need to upload your files and start the process again.")
           ,br()
           ,p("Q: Why does the progress bar stay still for awhile then jump ahead to completion?")
           ,p("A: It's a result of how the website processes uploaded files. 
              The progress bar does not move until after each file is completed. 
              Thus, if only one file is uploaded, the progress bar goes from 0% to 100% in one jump. 
              If three files are uploaded, the bar jumps from 0% to 33% to 66% to 100% as each file
              is completed. 
              Think of the progress bar as showing which file the website is currently processing, not
              as the actual progress towards processing each file.")
           ,br()
           ,p("Q: Why isn't my spreadsheet processing? The website just shuts down.")
           ,p("A: One common reason the site won't process input spreadsheets is because they are
              formatted incorrectly. 
              Make sure the formatting of your input spreadsheets is correct by checking it against 
              the template",
              a("here.", target = "_blank", href="continuous_data_template_2017_11_15.csv"),
              "If that does not fix the problem, contact the e-mail addresses listed on the 'Site introduction' tab.")
           ,br()
           ,p("Q: Can other people download my files from the website?")
           ,p("A: They should not be able to. 
              As soon as you upload a new set of data or close the tab in which you are viewing 
              the website, all of your files (inputs, outputs, USGS data) should be deleted. 
              If you do somehow get someone else's data (instead of or in addition to your own), 
              please contact us.")
           ,br()
           ,p("Q: Can I change the QC thresholds that the QC process uses?")
           ,p("A: Yes, you can. 
              Do so under the 'Advanced features' tab.
              The website will not record which thresholds you used for each output, so make sure you
              record that information somewhere.")
           ,br()
           ,p("Q: What is the 'Advanced features' tab for?")
           ,p("A: All four processes on this website produce status updates.
              After the process has completed, these messages are displayed on this tab.
              You don't need to refer to them unless there's an error, in which case you should send
              the console output to the contacts listed on this website.
              You can also upload your own QC threshold spreadsheet on this tab.")
           ,p("Q: Can I download data from different USGS gages at different time periods?")
           ,br()
           ,p("A: Not at this time. Currently, all USGS gages you enter will have data downloaded 
              over the same time period.")
           ,br()
           ,p("Q: I've gotta QC my data on the go. Can I use this site on my phone?")
           ,p("A: Mobile use of this app is untested. 
              Please let us know how it goes.
              Just remember that internet access is required.")
           ,br()
           ,p("Q: Why does the website header say 'preliminary'?")
           ,p("A: This website is still under development. Features are being added to it. 
              Moreover, it has not been approved for public release and is not hosted on
              an official EPA server.")
           ,br()
  )
  
)
)