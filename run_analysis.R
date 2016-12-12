# Download and unzip the file
inputDirectory = "data/raw"
dir.create(inputDirectory, recursive = TRUE)
download.file(
  url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
  destfile = paste(inputDirectory, "/dataset.zip", sep = ""),
  method = "curl"
)
unzip(
  paste(inputDirectory, "/dataset.zip", sep = ""),
  exdir = inputDirectory
)

dataPath = paste(inputDirectory, "/UCI HAR Dataset", sep = "")

#Function which reads a file containing only one column and converting the content to a vector
readVector <- function(filePath) {
  fileContent <- read.delim(filePath, header = FALSE)
  as.vector(fileContent$V1)
}

#The function which loads data from a specified directory
# TASK 4, note that the function sets the variable names
loadDataset <- function(parentDirectory, subDirectoryName) {
  columnNames <- readVector(paste(parentDirectory, "/features.txt", sep = "")) #reads the file containing colum names
  path <- paste(parentDirectory, "/", subDirectoryName, sep = "")  
  subjects <- readVector(paste(path, "/subject_", subDirectoryName, ".txt", sep = "")) #reads subject identifiers
  variables <- read.table( #reads the measurements
    paste(path, "/X_", subDirectoryName, ".txt", sep = ""),
    header = FALSE,
    colClasses = c("numeric"),
    col.names = columnNames
  )
  activities <- readVector(paste(path, "/y_", subDirectoryName, ".txt", sep = "")) #reads the activity identifiers
  cbind(subjects = subjects, variables, activities = activities) #creates a single dataset with all columns
}

# TASK 1
# Load both datasets and merge them
data <- {
  testData <- loadDataset(dataPath, "test")
  trainData <- loadDataset(dataPath, "train")
  rbind(testData, trainData)
}

# TASK 2
# Extracts subjects means, standard deviations, and activities
onlyMeanAndSD <- data[, grep("subjects|mean()|std()|activities", names(data))]

# TASK 3
# Reads activity labels
withActivityNames <- {
  activityLabels <- {
    path <- paste(dataPath, "/activity_labels.txt", sep = "")
    read.table(path, header = FALSE, col.names = c("id", "activity"))
  }
  
  # Merge activity ids with labels
  merged <- merge(onlyMeanAndSD, activityLabels, by.x = "activities", by.y = "id", all = TRUE)
  # Drop the activities column because it is redundant
  subset(merged, select=-c(activities))
}

# TASK 4 - note that the column names have been specified in the loadDataset function 

# TASK 5
aggregated <- aggregate(. ~ subjects + activity, data = withActivityNames, FUN = mean)

# Store the datasets (not a part of the assignment)
outputDirectory <- "data/processed"
dir.create(outputDirectory, recursive = TRUE)
write.table(withActivityNames, file=paste(outputDirectory, "/activities.txt", sep = ""), col.names = TRUE)
write.table(aggregated, file=paste(outputDirectory, "/means.txt", sep = ""), col.names = TRUE)
