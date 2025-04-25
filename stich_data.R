library(tidyverse)
library(eyetools)

# this bit reads in the files and uses part of the filename to make a new "subj" variable
fnams <- list.files("CSV Data", "ids", full.names = TRUE) # needed for reading data
subjs <- list.files("CSV Data", "ids") # needed for identifying subject numbers
data <- NULL
for (subj in 1:length(fnams)) {
  print(fnams[subj])
  pData <- read_csv(fnams[subj], col_types = cols(), col_names = FALSE) # read the data from csv
  pData <-
    pData %>%
    mutate(pNum = substr(subjs[subj],1,3)) %>%
    select(pNum, everything())
  data <- rbind(data, pData) # combine data array with existing data
}

id_data <- data %>% rename(trial_ID = X1)


# Process eye data

raw_data <- NULL

for (p in 1:2){

  fnams <- list.files("CSV Data", file_key, full.names = TRUE) # needed for reading data
  subjs <- list.files("CSV Data", file_key) # needed for identifying subject numbers

  for (subj in 1:length(fnams)) {

    print(fnams[subj])
    print(paste0("Read/process period: ", p))

    pData <- read_csv(fnams[subj], col_types = cols(), col_names = FALSE) # read the data from csv

    pData[pData==-1] <- NA

    pData <-
      pData %>%
      transmute(time = X6, left_x = X1*1920, left_y = X2*1080,
             right_x = X3*1920, right_y = X4*1080, trial = X5) %>% 
      group_by(trial) %>%
      mutate(time = round((time - time[1])/1000)) %>% 
      mutate(pID = substr(subjs[subj],1,3)) %>% 
      select(time, pID, trial, everything()) %>% 
      ungroup()

    # combine eyes
    pData <- combine_eyes(pData, "average")
    
    # interpolate
    pData <- interpolate(pData)
    
    # add period variable
    pData <- 
      pData %>% 
      mutate(period = p)

    raw_data <- rbind(raw_data, pData) # combine data array with existing data
    
  }
  
}

save(id_data, raw_data, file = "inj_unsw_EG_data.RData")

# Process time bin analysis

load("inj_unsw_EG_data.RData")

# Set AOIs
AOI_stims <- eyetools::create_AOI_df(3)

AOI_stims[1,] <- c(510, 540, 700, 500) # X, Y, W, H - left
AOI_stims[2,] <- c(1410, 540, 700, 500) # X, Y, W, H - right
AOI_stims[3,] <- c(960, 540, 150, 150) # X, Y, W, H - fixation

AOI_stims_names <- c("left", "right", "centre")

aoi_bin_data <- 
  eyetools::AOI_time_binned(data = raw_data, 
                            AOIs = AOI_stims, 
                            AOI_names = AOI_stims_names, 
                            bin_length = 2000)


fixation_data <- NULL

for (p in 1:2){

  print(paste0("Compute fixations period: ", p))
  
  period_raw <- 
    raw_data %>% 
    filter(period == p)
  
  period_fix <- 
    fixation_dispersion(period_raw) %>% 
    mutate(period = p)
  

  fixation_data <- rbind(fixation_data, period_fix)
  
}

save(id_data, fixation_data, aoi_bin_data, file = "inj_unsw_EG_data.RData")


fixation_data <- rbind(fixation_data, period_fix) # combine data array with existing data
