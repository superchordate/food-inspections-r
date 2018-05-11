acct = own %>% select( acct, legalnm ) %>% unique()
own %<>% select( -legalnm )

t = c( 
  "MEMBER",
  "SOLE PROPRIETOR",
  "TREASURER",
  "MANAGING MEMBER",
  "PRESIDENT",
  "VICE PRESIDENT",
  "MANAGER",
  "PRINCIPAL OFFICER",
  "INDIVIDUAL",
  "SECRETARY",
  "SHAREHOLDER",
  "CEO",
  "ASST. SECRETARY",
  "EXECUTIVE DIRECTOR",
  "PARTNER",
  "OTHER",
  "DIRECTOR",
  "GENERAL PARTNER",
  "LIMITED PARTNER",
  "NOT APPLICABLE",
  "SPOUSE",
  "TRUSTEE",
  "",
  "BENEFICIARY"
)
rm(t)
