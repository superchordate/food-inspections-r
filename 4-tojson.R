require(RMySQL)
require(jsonlite)
require(dplyr)

rm(list=ls(all=TRUE))
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # set directory to location of file.

# conn = dbConnect( MySQL(), dbname = 'project', username = 'root', password = 'root', host = 'localhost' ) # make sure this database exists if you want to use it.
source( '../connect.R') # this creates the connection object saved as 'conn'. You can create this separetly, I don't want to save my credentials here.

crmdist = dbGetQuery( conn, 'select * from crmdist' )
crm = dbGetQuery( conn, 'select * from crm' )

lic =  dbGetQuery( conn, 'select * from lic' )
addr = dbGetQuery( conn, 'select * from addr' )
acct_site_lic = dbGetQuery( conn, 'select * from acct_site_lic' ) 
acct = dbGetQuery( conn, 'select * from acct' ) 
liccode = dbGetQuery( conn, 'select * from lic_code' )

lic %<>% 
  left_join( addr, by = 'addrid' ) %>% select( -addrid ) %>% 
  left_join( acct_site_lic, by = 'licnum' ) %>%
  left_join( acct, by = 'acct' ) %>%
  left_join( liccode, by = 'liccodeid' ) %>% select( - liccodeid )
  
rm(addr,acct_site_lic,acct,liccode)

licnums = unique( lic$licnum ) %>% dplyr::sample_n( 1000 )

save( crmdist, crm, lic, file = '../data/4-tojson-pre.RData' )

# Lapply to get results in numbered list.
lics = lapply(
  
  # each license number.
  1:length(licnums), 
  
  function(i){
  
    # get history for this license.
    ilics = lic %>% filter( licnum == licnums[i] ) 
    
    # get single summary-level items for license.
    ilic = ilics %>% 
      group_by( licnum, legalnm ) %>% 
      summarize( 
        start = min(start, na.rm = T), 
        expir = max(expir, na.rm = T)
      )
    
    # get unique addresses with start/expir dates.
    iaddr = ilics %>% group_by( addr, city, st, zip, ward, precinct, policedist ) %>%
      summarize( start = min(start, na.rm = T), expir = max(expir, na.rm = T))
    
    # Bring in crime with distance.
      
      ilist = list()
      for( j in colnames( lic ) ) ilist[[j]] = ilic[[j]]
      
      icrim = ilics %>% select( 'latid', 'lngid' ) %>% 
        inner_join( crmdist, by = c( 'latid' = 'addr_latid', 'lngid' = 'addr_lngid' ) ) %>% 
        inner_join( crm, by = c( 'crm_latid' = 'latid', 'crm_lngid' = 'lngid' ) ) %>%
        select( -latid, -lngid, -crm_latid, -crm_lngid ) %>%
        unique()
      
    # Add array-type items, named.
    ilist$crime = icrim
    ilist$license_hist = ilics %>% select( licid, dba, apptype, start, expir, status, ssa )
    ilist$address = iaddr
    
    # Items we'll take the latest value only.
    ilics %<>% arrange( desc( expir ) ) 
    ilist$liccodedesc = ilics$liccodedesc[1]
    
    cat( length(licnums)-i, ' ' )
    
    return(ilist)
    
  }
)

write( toJSON( lics, pretty = TRUE, auto_unbox = TRUE ), '../data/licenses.json' )
