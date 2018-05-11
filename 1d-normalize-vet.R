# Assumes you've run 0-read.R.

# load('../data/0-load.RData')

# Add matching columns.
tomatch = function(x) gsub( '[^a-z]', '', tolower(trimws(x)) )

own %<>% mutate( 
  matchon = tomatch( paste0( fname, lname, legalnm ) )
)

vet %<>% mutate(
  matchon = tomatch( paste0( fname, lname, legalnm ) )
)

vet %<>% inner_join( own %>% select( matchon, ownid ), by = 'matchon' ) %>% select( -matchon ) %>% unique()
vet$vetid <- 1:nrow(vet)
own %<>% select( -matchon )

rm(tomatch)
