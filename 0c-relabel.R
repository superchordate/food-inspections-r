# load('../data/rout/0b-transform.RData')
fname = '../data/rout/0c-relabel.RData'
if( length( list.files( pattern = fname ) ) > 0 ){ load(fname) } else {
  
  # Clarify license Status. See https://data.cityofchicago.org/dataset/Business-Licenses/r5kz-chrr
  lic$status[ lic$status == 'AAC' ] <- 'Canceled'
  lic$status[ lic$status == 'AAI' ] <- 'Issued'
  lic$status[ lic$status == 'REA' ] <- 'Revocation Appealed'
  lic$status[ lic$status == 'REV' ] <- 'Revoked'
  
  lic$apptype[ lic$apptype == 'C_LOC' ] <- "Moving to New Location"
  lic$apptype[ lic$apptype == 'ISSUE' ] <- "New Issue"
  lic$apptype[ lic$apptype == 'RENEW' ] <- "Renew"
  lic$apptype[ lic$apptype == 'C_CAPA' ] <- "Change Capacity"
  lic$apptype[ lic$apptype == 'C_EXPA' ] <- "Expanded (Bus. w/ Liquor License)"
  lic$apptype[ lic$apptype == 'C_SBA' ] <- "C_SBA: Not Defined Yet"

  save( lic, own, inspect, vet, file = fname )

}