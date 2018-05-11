# Validate ids are unique per table.
validid = function(idcol){
  ndups = sum( duplicated( idcol ) )
  if(ndups>0) stop('id column not unique: ', ndups)
}
dropdups = function(x,idcol){
  startrows = nrow(x)
  x <- x[ !duplicated(idcol), ]
  cat('Removed ', startrows-nrow(x),'duplicated ids')
  return(x)
}

  acct_site_lic %<>% dropdups( acct_site_lic$licnum)
  validid(acct_site_lic$licnum)
  
  validid(addr$addrid)
  validid(busact$busactid)
  validid(inspect$inspectid)
  validid(inspect_viol$inspect_viol_id)
  validid(lic$licid)
  validid(lic_code$liccodeid)
  validid(own$ownid)
  validid(vet$vetid )
  validid(viol$violid)
  validid(acct$acct)
  
  # Fix data to prep for foreign keys.
  acct_site_lic <- acct_site_lic[ acct_site_lic$acct %in% acct$acct, ]
  lic %<>% filter( !is.na(licnum) ) %>% filter( licnum %in% acct_site_lic$licnum )
  acct_site_lic %<>% filter( !is.na(licnum) )
  inspect %<>% filter( licnum %in% acct_site_lic$licnum )
  inspect_viol %<>% filter( inspectid %in% inspect$inspectid )
  
  save( acct, acct_site_lic, addr, busact ,inspect, inspect_viol, lic, lic_code, own, vet, viol, file = '../data/rout/2-clean.RData' )
  
  rm(dropdups, validid)
  