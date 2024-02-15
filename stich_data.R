library(tidyverse)
library(eyetools)
# 
# # this bit reads in the files and uses part of the filename to make a new "subj" variable
# fnams <- list.files("CSV Data", "stim", full.names = TRUE) # needed for reading data
# subjs <- list.files("CSV Data", "stim") # needed for identifying subject numbers
# data <- NULL
# for (subj in 1:length(fnams)) {
#   print(fnams[subj])
#   pData <- read_csv(fnams[subj], col_types = cols(), col_names = FALSE) # read the data from csv
#   pData <- 
#     pData %>%
#     mutate(pNum = substr(subjs[subj],1,3)) %>%
#     select(pNum, everything())
#   data <- rbind(data, pData) # combine data array with existing data
# }
# 
# 
# 
# 


# process eye data

# Set AOIs
AOI_stims <- data.frame(matrix(nrow = 2, ncol = 4))
colnames(AOI_AGP) <- c("x", "y", "width_radius", "height")

AOI_stims[1,] <- c(460, 540, 200, 200) # X, Y, W, H - left
AOI_stims[2,] <- c(1520, 540, 200, 200) # X, Y, W, H - right
AOI_stims[3,] <- c(960, 540, 200, 200) # X, Y, W, H - right

AOI_stims_names <- c("left", "right", "centre")

# this bit reads in the files and uses part of the filename to make a new "subj" variable

for (p in 1:2){

  if (p == 1){
    file_key = "fb"
    
  }
  else{
    file_key = "stim"
  }

  fnams <- list.files("CSV Data", file_key, full.names = TRUE) # needed for reading data
  subjs <- list.files("CSV Data", file_key) # needed for identifying subject numbers

  data <- NULL

  for (subj in 1:length(fnams)) {

    print(fnams[subj])
    print(p)

    pData <- read_csv(fnams[subj], col_types = cols(), col_names = FALSE) # read the data from csv

    pData[sapply(pData, is.nan)] <- NA

    pData <-
      pData %>%
      select(time = X8, left_x = X1, left_y = X2,
             right_x = X4, right_y = X5, trial = X7)

    # combine eyes
    pData <- combine_eyes(pData, "average")

    # interpolate
    pData <- interpolate(pData)

    # mutate x/y to screen res
    pData <-
    pData %>%
      mutate(x = x*1920, y = y*1080,
             time = round(time/1000)) %>%
      group_by(trial) %>%
      mutate(time = time - time[1])

    fix_d <- fix_dispersion(pData)

    pData_AOI <-
      AOI_time(fix_data = fix_d,
               AOIs = AOI_AGP,
               AOI_names = AOI_names_AGP)

    pData_AOI <-
      pData_AOI %>%
      mutate(pNum = substr(subjs[subj],1,3), .before = trial)

    data <- rbind(data, pData_AOI) # combine data array with existing data


  }

  if (p == 1){
    eg_dec <- data
  } else{
    eg_fb <- data
  }

}

# # ICU data
# 
# # this bit reads in the files and uses part of the filename to make a new "subj" variable
# fnams <- list.files("CSV Data", "ICU", full.names = TRUE) # needed for reading data
# subjs <- list.files("CSV Data", "ICU") # needed for identifying subject numbers
# data <- NULL
# for (subj in 1:length(fnams)) {
#   pData <- read_csv(fnams[subj], col_types = cols(), col_names = FALSE) # read the data from csv
#   pData <- 
#     pData %>%
#     mutate(pNum = substr(subjs[subj],1,3),
#            q_num = c(1:24)) %>%
#     select(pNum, q_num, everything())
#   data <- rbind(data, pData) # combine data array with existing data
# }
# 
# rev_code_Qs <-  c(1, 3, 5, 8, 13, 14, 15, 16, 17, 19, 23, 24)
# 
# ICU_data <- 
#   data %>% 
#   rename(response = X1, time = X2) %>% 
#   mutate(rev_coded_resp = case_when(q_num %in% rev_code_Qs ~ 5 - response,
#                                     TRUE ~ response), 
#          .after = response)
# 
# 
# ICU_score <- 
#   ICU_data %>% 
#   group_by(pNum) %>% 
#   summarise(ICU_mean = sum(rev_coded_resp)-24)
# 
# data <- cbind(training_data, eg_dec[,3:5], eg_fb[,3:5])
# 
# data <- 
#   left_join(data, ICU_score, by = "pNum")
# 
# 
# save(data, file = "AGP_5R_data.RData")
# 
# spatial_plot(AOIs = AOI_AGP)
