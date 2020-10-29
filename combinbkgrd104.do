tempfile x1 x2
use ../data/bkgrd2015y_de,clear
decode AGE_2015_AGE_NEW,gen(iage104)
decode EDUC_NEW,gen(ieduc)
save `x1',replace

use ../data/bkgrd2015o_de,clear
decode AGE_2015_AGE_NEW,gen(iage104)
decode EDUC_NEW,gen(ieduc)
save `x2',replace

use `x1',clear
append using `x2'
sencode iage104,gen( age104) gsort(iage104)
sencode ieduc,gen(educ) gsort(ieduc)

save ../transfer/bkgr104,replace

