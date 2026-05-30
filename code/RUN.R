# Import Environment
if (!require("renv")) {
  install.packages("renv")
  library(renv)
}
renv::restore()

# Import Library
source("1_ImportLibrary.R")

# Import Data
source("2_ImportData.R")

# Feature Engineering
source("3_FeatureEngineering.R")

# Target Population
source("4_TargetPopulation.R")

# Descriptive Statistics
source("5_DescriptiveStatistics.R")

# Model Estimation
source("6_ModelEstimation.R")

# Robustness Checks
source("7_RobustnessChecks.R")

