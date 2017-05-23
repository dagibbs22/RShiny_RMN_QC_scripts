testcsv <- function(y,z) {
  setwd("C:\\Users\\dgibbs\\Documents\\Projects\\Regional_Monitoring_Networks\\Continuous_data_processing\\RShiny RMN QC scripts\\RMN_continuous_data_QC_20170515\\Data2_QC")
  x <- rpois (y, z)
  testcsv <- write.csv(x, file = "testcsv.csv")
  return (testcsv)
}