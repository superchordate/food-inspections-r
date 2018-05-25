# load('../data/rout/0a-raw.RData')
fname = '../data/rout/0b-transform.RData'
if( length( list.files( pattern = fname) ) > 0 ){ load(fname) } else {

    lic %<>% 
        select( -`PAYMENT DATE`, -`DATE ISSUED`, -ID, -`LEGAL NAME`, -LOCATION, -`WARD PRECINCT` ) %>% 
        rename( 
            start = `LICENSE TERM START DATE`,
            expr = `LICENSE TERM EXPIRATION DATE`,
            appcreated = `APPLICATION CREATED DATE`,
            statuschgd = `LICENSE STATUS CHANGE DATE`,
            licid = `LICENSE ID`,
            busactid = `BUSINESS ACTIVITY ID`,
            busact = `BUSINESS ACTIVITY`,
            licnum = `LICENSE NUMBER`,
            apptype = `APPLICATION TYPE`,
            appcreate = `APPLICATION CREATED DATE`,
            appcompl = `APPLICATION REQUIREMENTS COMPLETE`,
            start = `LICENSE TERM START DATE`,
            expir = `LICENSE TERM EXPIRATION DATE`,
            approved = `LICENSE APPROVED FOR ISSUANCE`,
            status = `LICENSE STATUS`,
            statusch = `LICENSE STATUS CHANGE DATE`,
            ssa = SSA,
            liccodeid = `LICENSE CODE`,
            liccodedesc = `LICENSE DESCRIPTION`,
            appcond = `CONDITIONAL APPROVAL`,
            addr = ADDRESS, 
            city = CITY, 
            st = STATE, 
            zip = `ZIP CODE`, 
            ward = `WARD` ,
            precinct = `PRECINCT`, 
            lat = LATITUDE, 
            lng = LONGITUDE, 
            acct = `ACCOUNT NUMBER`,
            site = `SITE NUMBER`,
            policedist = `POLICE DISTRICT`,
            dba = `DOING BUSINESS AS NAME`
        ) %>% mutate_at(
            vars( approved, start, appcreate, appcompl, statusch, expir ), 
            funs( lubridate::mdy )
        ) %>% mutate(
          dba = gsub('[^0-9A-z -]', '', dba )
        )
    
    inspect %<>%
        select( 
            -Location, -Address, -City, -State,  -Zip, -Latitude, -Longitude, -`DBA Name`, -`AKA Name` ) %>%
        rename( 
            inspectid = `Inspection ID`,
            licnum = `License #`,
            facility = `Facility Type`,
            risk = Risk,
            date = `Inspection Date`,
            type = `Inspection Type`,
            result = Results,
            viol = Violations
        ) %>% 
        mutate(
            date = mdy(date)
        )

    own$ownid <- 1:nrow(own)
    own %<>% 
        select( -Suffix, -`Owner Middle Initial` ) %>% 
        rename(
            acct = `Account Number`,
            fname = `Owner First Name`,
            lname = `Owner Last Name`,
            legalent = `Legal Entity Owner`,
            legalnm = `Legal Name`,
            title = Title
        )

    vet$vetid <- 1:nrow(vet)
    vet %<>% 
        rename(
            fname = `Primary Owner First Name`,
            lname = `Primary Owner Last Name`,
            legalnm = `Business Name`,
            cert = `Certification Date`,
            renew = `Renewal Date`,
            expir = `Expiration Date`
        ) %>% 
        mutate_at(
            vars( cert, renew, expir ),
            funs(mdy)
        ) %>% 
        select( fname, lname, legalnm, cert, renew, expir )
    
    crm %<>% select( 
      -`Updated On`, -Beat, -District, - Ward, -`Community Area`, -Year, 
      -Location, -Block, -IUCR, -`X Coordinate`, -`Y Coordinate`, -ID, -`FBI Code` 
    )
    
    crm %<>% rename(
      casenum = `Case Number`,
      date = Date,
      type = `Primary Type`,
      desc = Description,
      loc = `Location Description`,
      arrest = Arrest,
      domestic = Domestic,
      lat = Latitude,
      lng = Longitude
    )
    
    crm %<>% mutate(
      date = lubridate::parse_date_time(date, 'm/d/y I:M:S p'),
      arrest = ifelse( arrest == 'true', 1, 0 ),
      domestic = ifelse( domestic == 'true', 1, 0 )
    )
    
    crm %<>% filter( domestic == 0 ) %>% select( -domestic )
    crm %<>% filter( ! loc %in% c( 'RESIDENCE', 'APARTMENT', 'OTHER' ), date > mdy('1/1/2008') )
    
    
    fin %<>% mutate(
      date = mdy(date),
      finid = 1:nrow(fin)
    )

  save( lic, own, inspect, vet, file = fname )

}
  
  # Unique Account Numbers.
  #accnt = data.frame(
  #  account_number = unique(c(lic$`ACCOUNT NUMBER`, own$`Account Number`) ),
  #  stringsAsFactors = FALSE
  #)