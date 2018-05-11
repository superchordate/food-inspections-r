# Add addresses to address data.
lic %<>% mutate(
  addrlkup = paste0( addr, city, st, zip, ward, precinct, policedist, lat, lng )
)

addr = lic %>% select( addr, city, st, zip, ward, precinct, policedist, addrlkup, -lat, -lng ) %>% unique()
addr$addrid <- 1:nrow(addr)

lic %<>% 
  select( -addr, -city, -st, -zip, -ward, -precinct, -policedist, -lat, -lng ) %>%
  left_join( addr %>% select( addrlkup, addrid), by = 'addrlkup' ) %>%
  select( -addrlkup )
          
addr %<>% select( -addrlkup )
