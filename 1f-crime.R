require(geosphere)

# distance testing.
distHaversine( round( addr[ 1, c( 'lat', 'lng' ) ], 4 ), round( crm[ 2, c( 'lat', 'lng' ) ], 4 ) ) / 1609.34

crm %<>% mutate( latr4 = round(lat,4), lngr4 = round(lng,4) )
addr %<>% mutate( latr4 = round(lat,4), lngr4 = round(lng,4) )

addrll = addr %>% select( latr4, lngr4 ) %>% unique()
crll = crm %>% select( latr4, lngr4 ) %>% unique()

addrll$addrllid = 1:nrow(addrll)
crll$crllid = 1:nrow(crll)

if(exists('xw')) rm(xw)
lapply( 1:nrow(addrll), function(i){
  
  idt = distHaversine(
    addrll[i, c('lngr4','latr4') ],
    crll %>% select( lngr4, latr4 )
  )
  isel = !is.na(idt) & idt < 1000
  idt = data.frame( rep( addrll[i, 'addrllid'], sum(isel) ), crll$crllid[ isel ], dist = idt[ isel ] )
  
  if( exists('xw') ){ 
    xw <<- bind_rows(xw,idt)
  } else {
    xw <<- idt
  }
  if(i%%100==0) cat('Finished ', i, ' of ', nrow(addrll), round(i/nrow(addrll),2), '\n' )
})

# Attach rounded lat/lng.
xw %<>% left_join( crll %>% select( crllid, crm_latr4 = latr4, crm_lngr4 = lngr4 ), by ='crllid' )
xw %<>% left_join( addrll %>% select( addrllid, addr_latr4 = latr4, addr_lngr4 = lngr4 ), by ='addrllid' )
xw %<>% select( -crllid, -addrllid )


#latlng = bind_rows(
#  crm %>% select( lat, lng ) %>% mutate( latr4 = round(lat,4), lngr4 = round(lng,4) ),
#  addr %>% select( lat, lng ) %>% mutate( latr4 = round(lat,4), lngr4 = round(lng,4) )
#) %>% unique()
#latlng$latlngid = 1:nrow(latlng)

# Create lat/lng ids, rounded and un-rounded.
latlngr4 = data.frame(
  latlngr4 = unique( c( crm$latr4, crm$lngr4, addr$latr4, addr$lngr4 ) )
)
latlng =data.frame(
  latlng = unique( c( crm$lat, crm$lng, addr$lat, addr$lng ) )
)
latlngr4$latlngr4id = 1:nrow(latlngr4)
latlng$latlngid = 1:nrow(latlng)

# Replace lat/lngs with IDs
crm %<>% left_join( latlng, by = c( 'lat' = 'latlng' ) ) %<>% rename( latid = latlngid )
crm %<>% left_join( latlng, by = c( 'lng' = 'latlng' ) ) %<>% rename( lngid = latlngid )
crm %<>% left_join( latlngr4, by = c( 'latr4' = 'latlngr4' ) ) %<>% rename( latr4id = latlngr4id )
crm %<>% left_join( latlngr4, by = c( 'lngr4' = 'latlngr4' ) ) %<>% rename( lngr4id = latlngr4id )
crm %<>% select( -lat, -lng, -latr4, -lngr4 )

addr %<>% left_join( latlng, by = c( 'lat' = 'latlng' ) ) %<>% rename( latid = latlngid )
addr %<>% left_join( latlng, by = c( 'lng' = 'latlng' ) ) %<>% rename( lngid = latlngid )
addr %<>% left_join( latlngr4, by = c( 'latr4' = 'latlngr4' ) ) %<>% rename( latr4id = latlngr4id )
addr %<>% left_join( latlngr4, by = c( 'lngr4' = 'latlngr4' ) ) %<>% rename( lngr4id = latlngr4id )
addr %<>% select( -lat, -lng, -latr4, -lngr4 )

xw %<>% left_join( latlngr4, by = c( 'crm_latr4' = 'latlngr4' ) ) %<>% rename( crm_latr4id = latlngr4id )
xw %<>% left_join( latlngr4, by = c( 'crm_lngr4' = 'latlngr4' ) ) %<>% rename( crm_lngr4id = latlngr4id )
xw %<>% left_join( latlngr4, by = c( 'addr_latr4' = 'latlngr4' ) ) %<>% rename( addr_latr4id = latlngr4id )
xw %<>% left_join( latlngr4, by = c( 'addr_lngr4' = 'latlngr4' ) ) %<>% rename( addr_lngr4id = latlngr4id )
xw %<>% select( -crm_latr4, -crm_lngr4, -addr_latr4, -addr_lngr4 )

# Round distance.
xw %<>% mutate( dist = round(dist,0) )

# Remove crime that doesn't link back.
crm %<>% filter( latr4id %in% xw$crm_latr4id | lngr4id %in% xw$crm_lngr4id )

dbWriteTable(
  conn,
  name='crm', 
  value = crm,
  overwrite = TRUE,
  row.names = FALSE
)
dbWriteTable(
  conn,
  name='addr', 
  value = addr,
  overwrite = TRUE,
  row.names = FALSE
)
dbWriteTable(
  conn,
  name='crmdist', 
  value = xw,
  overwrite = TRUE,
  row.names = FALSE
)
dbWriteTable(
  conn,
  name='latlng', 
  value = latlng,
  overwrite = TRUE,
  row.names = FALSE
)
