
adopath + "D:\Activity\elderman\utils"

local dtafiles : dir "../data" files "*.dta"

foreach item in `dtafiles' {

 use ../data/`item',clear
 
 
 capture confirm variable QTYPE
 if _rc==0 {
   capture safedrop qtype
   decode QTYPE,gen(qtype)
 }
 capture confirm variable SER_NO4
 if _rc==0 {
   capture safedrop ser_no4
   decode SER_NO4,gen(ser_no4)
 }
 save ../data/`item',replace
 
}


