require(dplyr)
require(magrittr)
# require(bc) # not necessary here but sometimes I use my own package. Install with devtools::install_github("superchordate/r-bc").
require(data.table)
require(lubridate)
rm(list=ls(all=TRUE))
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # set directory to location of file.

# Read files. Assumes you have them in a folder in the parent, called 'data'.

  setwd('../data')

  # Busines licenses.
  lic = data.table::fread('Business_Licenses.csv') %>% # https://data.cityofchicago.org/Community-Economic-Development/Business-Licenses/r5kz-chrr
    mutate(
      `LICENSE TERM START DATE` = mdy(`LICENSE TERM START DATE`),
      `LICENSE TERM EXPIRATION DATE` = mdy(`LICENSE TERM EXPIRATION DATE`)
    )
  
  # Clarify license Status. See https://data.cityofchicago.org/dataset/Business-Licenses/r5kz-chrr
  lic$`LICENSE STATUS`[ lic$`LICENSE STATUS` == 'AAC' ] <- 'Canceled'
  lic$`LICENSE STATUS`[ lic$`LICENSE STATUS` == 'AAI' ] <- 'Issued'
  lic$`LICENSE STATUS`[ lic$`LICENSE STATUS` == 'REA' ] <- 'Revocation Appealed'
  lic$`LICENSE STATUS`[ lic$`LICENSE STATUS` == 'REV' ] <- 'Revoked'
  
  lic$`APPLICATION TYPE`[ lic$`APPLICATION TYPE` == 'C_LOC' ] <- "Moving to New Location"
  lic$`APPLICATION TYPE`[ lic$`APPLICATION TYPE` == 'ISSUE' ] <- "New Issue"
  lic$`APPLICATION TYPE`[ lic$`APPLICATION TYPE` == 'RENEW' ] <- "Renew"
  lic$`APPLICATION TYPE`[ lic$`APPLICATION TYPE` == 'C_CAPA' ] <- "Change Capacity"
  lic$`APPLICATION TYPE`[ lic$`APPLICATION TYPE` == 'C_EXPA' ] <- "Expanded (Bus. w/ Liquor License)"
  lic$`APPLICATION TYPE`[ lic$`APPLICATION TYPE` == 'C_SBA' ] <- "C_SBA: Not Defined Yet"

  # Business owners.
  own = fread('Business_Owners.csv') # https://data.cityofchicago.org/Community-Economic-Development/Business-Owners/ezma-pppn
  cat( 
    sum(lic$`ACCOUNT NUMBER` %in% own$`Account Number` )/nrow(lic) * 100,
    '% licenses match to owners.\n'
  )

  # Food inspections.
  food = fread('Food_Inspections.csv') # https://data.cityofchicago.org/Health-Human-Services/Food-Inspections/4ijn-s7e5
  food %<>% 
    mutate(
      `Inspection Date` = mdy(`Inspection Date`)
    ) 
  cat(
    sum( food$`License #` %in% lic$`LICENSE NUMBER` )/nrow(food)*100,
    '% inspections match to license\n'
  )

  # Filter only to licenses that have a food inspections.
  lic %<>% filter( `LICENSE NUMBER` %in% food$`License #` )
  
  # Unique Account Numbers.
  accnt = data.frame(
    account_number = unique(c(lic$`ACCOUNT NUMBER`, own$`Account Number`) ),
    stringsAsFactors = FALSE
  )

 # Vet-owned business.
 vet = fread('Veteran_Owned_Businesses.csv') # https://data.cityofchicago.org/Administration-Finance/Veteran-Owned-Businesses/czzw-ymcb
