require(dplyr)
require(magrittr)
# require(bc) # not necessary here but sometimes I use my own package. Install with devtools::install_github("superchordate/r-bc").
require(data.table)
require(lubridate)
rm(list=ls(all=TRUE))
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # set directory to location of file.

# Read files. Assumes you have them in a folder in the parent, called 'data'.

fname = '../data/rout/0a-raw.RData'

if( length( list.files( pattern = fname ) ) > 0 ){ load(fname) } else {
  
  # Busines licenses.
  lic = data.table::fread('../data/Business_Licenses.csv') # https://data.cityofchicago.org/Community-Economic-Development/Business-Licenses/r5kz-chrr
  
  # Business owners.
  own = fread('../data/Business_Owners.csv') # https://data.cityofchicago.org/Community-Economic-Development/Business-Owners/ezma-pppn
  
  # food inspections.
  inspect = fread('../data/Food_Inspections.csv') # https://data.cityofchicago.org/Health-Human-Services/inspect-Inspections/4ijn-s7e5
  
  # Filter only to licenses that have a inspect inspections.
  lic %<>% filter( `LICENSE NUMBER` %in% inspect$`License #` )
  
  # Vet-owned business.
  vet = fread('../data/Veteran_Owned_Businesses.csv') # https://data.cityofchicago.org/Administration-Finance/Veteran-Owned-Businesses/czzw-ymcb
  
  crm = fread( '../data/Crimes_-_2001_to_present.csv')# https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2
  
  # https://www.nasdaq.com/symbol/dri/historical
  fin = bind_rows( 
      fread( '../data/dri10yr.csv' ) %>% mutate( sym = 'DRI' ),
      fread( '../data/xly10yr.csv' ) %>% mutate( sym = 'XLY')
  )
  
  save( lic, own, inspect, vet, crm, file = fname )

}
