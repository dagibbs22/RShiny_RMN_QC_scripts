# Get R libraries
# Installs a defined set of libraries
# Created: 20080527, Erik.Leppo@tetratech.com
################################################
# Select mirror before running the rest of the script
################################################
# set CRAN mirror 
#(loads gui in R; in R-Studio select ## of mirror in Console pane)
# If know mirror can use "ind=" in 2nd statement and comment out (prefix line with #) the first.
chooseCRANmirror()
#chooseCRANmirror(ind=21)
################################################
# must run "chooseCRANmirror()" by itself before running the rest of the script


# libraries to be installed
data.packages = c(                  
                  "devtools"        # install helper for non CRAN libraries
                  ,"installr"       # install helper
                  ,"digest"         # caused error in R v3.2.3 without it
                  ,"dataRetrieval"  # loads USGS data into R
                  ,"knitr"          # create documents in other formats (e.g., PDF or Word)
                  ,"doBy"           # summary stats
                  ,"zoo"            # z's ordered observations, use for rolling sd calc
                  ,"htmltools"      # needed for knitr and doesn't always install properly with Pandoc
                  ,"rmarkdown"      # needed for knitr and doesn't always install properly with Pandoc
                  ,"htmltools"      # a dependency that is sometimes missed.
                  ,"evaluate"       # a dependency that is sometimes missed.
                  ,"highr"          # a dependency that is sometimes missed.
                  ,"rmarkdown"      # a dependency that is sometimes missed.
#                 ,"reshape"        # list to matrix
#                 ,"lattice"        # plotting
#                 ,"waterData"      # QC of hydro time series data
#                 ,"summaryBy"      # used in summary stats
                  )


# install packages via a 'for' loop
for (i in data.packages) {
  #install.packages("doBy",dependencies=TRUE)
  install.packages(i)
} # end loop

###############
library(devtools)
install_github("leppott/ContDataQC")  #QC scripts




