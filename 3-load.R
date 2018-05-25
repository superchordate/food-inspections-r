
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # set directory to location of file.
load('../data/rout/2-clean.RData')

require(RMySQL)

source( '../connect.R') # this creates the connection object saved as 'conn'. You can create this separetly, I don't want to save my credentials here.

if(T) for( i in c( 'acct', 'acct_site_lic', 'addr', 'busact', 'inspect', 'inspect_viol', 'lic', 'lic_code', 'own', 'vet', 'viol' ) ){
  idt = eval(parse(text=i))
  dbWriteTable(
    conn,
    name=i, 
    value = idt,
    overwrite = TRUE,
    row.names = FALSE
  )
  cat( 'loaded', i, '\n')
  rm(idt,i)
}


dbWriteTable(
  conn,
  name='crmdist', 
  value = xw,
  overwrite = TRUE,
  row.names = FALSE
)

crm %<>% mutate( crm_lat_round4 = round( lat, 4), crm_lng_round4 = round( lng, 4) ) %>% select( -lat, -lng )
