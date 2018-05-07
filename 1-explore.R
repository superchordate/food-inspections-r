# Assumes you've run 0-read.R.

# Explore one account.
owns = own %>% filter( `Account Number` == 1554 )
lics = lic %>% filter( `ACCOUNT NUMBER` == 1554 ) %>% arrange( `LICENSE TERM START DATE` )
View(owns)
View(lic)