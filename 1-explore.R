# Assumes you've run 0-read.R.

# Explore one account.

  ian = 1554  

  # Owners
  owners = own %>% filter( `Account Number` == ian )
  
  # Licenses. 
  # We may need to get license numbers first in case licenense change accounts. I'm not sure if this is the case.
  # Either way, we will need it for inspections.
  license_numbers = lic$`LICENSE NUMBER`[ lic$`ACCOUNT NUMBER` == ian ] %>% unique()
  licenses = lic %>% filter( `LICENSE NUMBER` %in% license_numbers ) %>% arrange( `LICENSE TERM START DATE` )
  
  # Inspections.
  inspections = food %>% filter( `License #` %in% license_numbers ) %>% arrange(`Inspection Date`)
  
  View(owners)
  View(licenses)
  View(inspections)
