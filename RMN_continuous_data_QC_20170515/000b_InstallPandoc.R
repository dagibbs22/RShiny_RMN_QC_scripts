# Installs non-R utilities
# Created: 20160303, Erik.Leppo@tetratech.com
################################################
# Assume have necessary libraries installed (devtools and installr)
# this script only installs Pandox

# # Get packages not on CRAN
# # (can ignore error about Rtools.  It is not needed.)
# ## StreamThermal
# library(devtools)
# install_github("StreamThermal","tsangyp",ref="v1.0")
## pandoc
require(installr)
install.pandoc()
# above won't work if don't have admin rights on your computer.
# Alternative = Download the file below and have your IT dept install for you.
#https://github.com/jgm/pandoc/releases/download/1.16.0.2/pandoc-1.16.0.2-windows.msi
# help for installing via command window
# http://www.intowindows.com/how-to-run-msi-file-as-administrator-from-command-prompt-in-windows/


