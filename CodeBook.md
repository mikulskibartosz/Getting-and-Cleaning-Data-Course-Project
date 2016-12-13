---
title: "CodeBook"
output: html_document
---



# Data description
The data/processed directory contains data derived from A Public Domain Dataset for Human Activity Recognition Using Smartphones. The research was conducted by Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz.
The dataset and the description of the research is available on the following website: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

# Variable descriptions

## File activities.txt
* subjects - the identifier of a person who has participated in the research
* activity - the name of an activity performed by the subject when the measurements were being collected
* measurements - values described below

### Measurement variables
The dataset contains means and standard deviation values.
If a variable is a mean its label contains: "mean", if the label contains: "std" the variable is a standard deviation value.

The values have been described in the codebook of the raw dataset.
Please find below the description copied from the feature_info.txt file.

> The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 
> 
> Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 
> 
> Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 
> 
> These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

## File means.txt
The dataset contains mean value of the variables from activities.txt file.
The data have been grouped by the subject identifier and the type of activity.

The dataset contains the following values:
* subject - the identifier of the person who has participated in the research
* activity - the name of an activity performed by the subject when the measurements were being collected
* means - the means of the measurements from activities.txt file (description above)

# Data transformations

## Download and unzip the file
Firstly, the data was downloaded and extracted to the "data/raw" directory. 

```r
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
```

Specify the data directory location


## Function which reads a file containing only one column and converting the content to a vector

```r
readVector <- function(filePath) {
  fileContent <- read.delim(filePath, header = FALSE)
  as.vector(fileContent$V1)
}
```

## The function which loads data from a specified directory
TASK 4, note that the function sets the variable names

```r
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
```

## TASK 1 (and TASK 4) - Load both datasets and merge them
Data from both datasets were loaded in memory and merged.
Note that the loadDataset function reads not only the variable values but also the variable labels, subject identifiers and identifiers of the activities. Therefore the dataset produced by the function contains all requred information and is properly described.

```r
data <- {
  testData <- loadDataset(dataPath, "test")
  trainData <- loadDataset(dataPath, "train")
  rbind(testData, trainData)
}
```

## TASK 2 - Extracts subjects, means, standard deviations, and activities
Redundant columns were removed from the dataset. According to the specification the dataset should contain only means and standard deviations. Additionally it must contain also columns required in tasks 3 and 5.
The following code retains only subjects, means, standard deviations and activity identifiers.

```r
onlyMeanAndSD <- data[, grep("subjects|mean()|std()|activities", names(data))]
```

## TASK 3 - Reads activity labels
Activity identifiers were replaced with activity names.

```r
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
```

## TASK 4 - note that the column names have been specified in the loadDataset function 

## TASK 5
A separate dataset containing means of the variables grouped by subject and activity was created.


## Store the datasets
Both datasets were stored in the "data/processed" directory.

```r
outputDirectory <- "data/processed"
dir.create(outputDirectory, recursive = TRUE)
write.table(withActivityNames, file=paste(outputDirectory, "/activities.txt", sep = ""), col.names = TRUE)
write.table(aggregated, file=paste(outputDirectory, "/means.txt", sep = ""), col.names = TRUE)
```
