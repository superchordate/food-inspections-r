# Assumes you've run 0-read.R.

load('../data/rout/0c-relabel.RData')

# Read files. Assumes you have them in a folder in the parent, called 'data'.

# Get unique licnese codes.
lic_code = lic %>% select( liccodeid, liccodedesc ) %>% unique()
lic %<>% select( -liccodedesc )

# Unique bus activities.
# TODO = bus act has multiple delimited by |. These should be split out to a new table.
busact = lic %>% select( busactid, busact) %>% unique()
lic %<>% select( -busact )

# Mapping account number, site number, to license number. Except for License Number 1000049, 1576631 this is a direct map.
acct_site_lic = lic %>% select( acct, site, licnum ) %>% unique()
lic %<>% select( -acct, -site )

# Extract vilations.
#t = strsplit( inspect$Violations, '[|]' )
#t2 = data.frame( inspectid = numeric(), text = character() )
#for( i in 1:length(t) ){
#  idt = t[[i]]
#  t2 %<>% bind_rows( data.frame( inspectid = rep( inspect$inspectid[i], length(idt) ), text = idt, stringsAsFactors = FALSE ) )
#  if( i %% 100 ) cat( 'i of ', length(t), '\n' )
#}

# Violations.
viol = readRDS('../data/rout/inspectdesc.RDS')
viol %<>% select( -stringAsFactors )
viol$text <- trimws( viol$text )

# Get the id from the violation.
viol$violid = gsub( '^([0-9]+[.]) .+$', '\\1', viol$text )
viol$violid[ viol$violid == viol$text ] <- NA # these didn't work.
viol$violid = gsub( '[.]', '', viol$violid )
viol$text <- trimws( gsub( '^([0-9]+[.]) ', '', viol$text ) ) # remove it.
viol$violid <- as.numeric( viol$violid )

viol$comments <- gsub( '^.+ - Comments: (.+$)', '\\1', viol$text )
viol$text <- gsub( '(^.+) - Comments: .+$', '\\1', viol$text )
viol$comments[ viol$comments == viol$text ] <- NA # these didn't work.


viol$severity <- gsub( '^.+[.] ([A-Z ]+[0-9-]{6,})$', '\\1', viol$comments )
viol$comments <- gsub( '(^.+[.]) [A-Z ]+[0-9-]{6,}$', '\\1', viol$comments )
viol$severity[ viol$comments == viol$severity ] <- NA # these didn't work.

viol$num <- gsub( '^[A-Z ]+ ([0-9-]{6,})$', '\\1', viol$severity )
viol$severity <- gsub( '(^[A-Z ]+) [0-9-]{6,}$', '\\1', viol$severity )
viol$num[ viol$num == viol$severity ] <- NA # these didn't work.

inspect_viol = viol %>% select( inspectid, violid, comments, severity, num ) %>% ungroup()
inspect_viol$inspect_viol_id = 1:nrow(inspect_viol)

inspect_viol %<>% mutate(
  severity = gsub( 'ISSUED','', severity ),
  severity = trimws(severity),
  severity = gsub( 'VIOLATIONS','VIOLATION', severity ),
  comments = ifelse( nchar(comments) > 255, paste0( substring(comments, 1, 255), '...' ), comments )
)

viol %<>% group_by( violid, text ) %>% summarize( n = n() ) %>% ungroup() %>% arrange( desc(n) ) %>% filter( !duplicated(violid) ) %>% select( -n )

inspect %<>% select( -viol )
