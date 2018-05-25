

addrall = addr %>% select( lat, lng ) %>% unique()
crll = crm %>% filter( date > mdy('1/1/2008') ) %>% select( clat = lat, clng = lng ) %>% unique() # 6,591,364 rows to 855,112
crll %<>% mutate( clat = round(clat,4), clng = round(clng,4) ) %>% unique() # 443,032

addrall$addrallid = 1:nrow(addrall)
crll$crllid = 1:nrow(crll)

# xwdist = merge( addrall[1:1000], crll, all = T)

require(geosphere)

if(exists('xw'))rm(xw)
lapply( 1:nrow(addrall), function(i){
  idt = distHaversine(
    addrall[i, c('lng','lat') ],
    crll %>% select( clng, clat )
  )
  isel = !is.na(idt) & idt < 500
  idt = data.frame( rep( addrall[i, 'addrallid'], sum(isel) ), crll$crllid[ isel ], dist = idt[ isel ] )
  if( exists('xw') ){ 
    xw <<- bind_rows(xw,idt)
  } else {
    xw <<- idt
  }
  if(i%%1000==0) cat('Finished ', i, ' of ', nrow(addrall), round(i/nrow(addrall),2), '\n' )
})

xw %<>% left_join( crll %>% select( crllid, crm_lat_round4 = clat, crm_lng_round4 = clng ), by ='crllid' )
xw %<>% left_join( addrall %>% select( addrallid, addr_lat = lat, addr_lng = lng ), by ='addrallid' )
xw %<>% select( -crllid, -addrallid )

t = xw %>% left_join( addr %>% select( addrid, lat, lng ), by = c('addr_lat' = 'lat', 'addr_lng' = 'lng' ))


latlng = unique( c( crm$crm_lat_round4, crm$crm_lng_round4, round( addr$lat, 4 ), round( addr$lng, 4 ) ) )
latlng = data.frame( latlngid = 1:length(latlng), latlng = latlng )

crm %<>% left_join( latlng, by = c( 'crm_lat_round4' = 'latlng' ) ) %<>% rename( latid = latlngid )
crm %<>% left_join( latlng, by = c( 'crm_lng_round4' = 'latlng' ) ) %<>% rename( lngid = latlngid )
crm %<>% select( -crm_lat_round4, -crm_lng_round4 )

addr %<>% mutate( lat = round(lat,4), lng = round(lng,4) )
addr %<>% left_join( latlng, by = c( 'lat' = 'latlng' ) ) %<>% rename( latid = latlngid )
addr %<>% left_join( latlng, by = c( 'lng' = 'latlng' ) ) %<>% rename( lngid = latlngid )
addr %<>% select( -lat, -lng )

xw %<>% left_join( latlng, by = c( 'crm_lat_round4' = 'latlng' ) ) %<>% rename( crm_latid = latlngid )
xw %<>% left_join( latlng, by = c( 'crm_lng_round4' = 'latlng' ) ) %<>% rename( crm_lngid = latlngid )
xw %<>% left_join( latlng, by = c( 'addr_lat' = 'latlng' ) ) %<>% rename( addr_latid = latlngid )
xw %<>% left_join( latlng, by = c( 'addr_lng' = 'latlng' ) ) %<>% rename( addr_lngid = latlngid )
xw %<>% select( -crm_lat_round4, -crm_lng_round4, -addr_lat, -addr_lng )
xw %<>% mutate( dist = round(dist,0) )

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
