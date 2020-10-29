 
adopath + "D:\Activity\elderman\utils"

use ../data/t15y_de,clear
set linesize 255

local maxscore 0
local pcount 20
forvalues idx=1/`pcount' {
  qui myRecode C3_`idx',gen(dise_`idx'a) reverse base(0) label("dise")
  local maxscore =`maxscore'+r(max) 
}

capture safedrop y1 
tempvar tmp
egen `tmp' = rowtotal(dise_*a)

gen y1 =(`tmp')/(`maxscore')*100 
label variable y1 "慢性疾病個數(反)"
capture drop `tmp'

//y2

local maxscore 0
local pcount 6
forvalues idx=1/`pcount' {
  qui myRecode C16_`idx',gen(ADL_`idx'a) reverse base(0) label("ADL")
  local maxscore =`maxscore'+r(max) 
}

capture safedrop y2 
tempvar tmp
egen `tmp' = rowtotal(ADL_*a)
gen y2 =(`tmp')/(`maxscore')*100 
label variable y2 "日常障礙(反)"
capture drop `tmp'
  
// Y3   身體功能量表(負向)   
// 沒困難,0-3 基底0
local maxscore 0
local pcount 10
forvalues idx=1/`pcount' {
  qui myRecode C13_`idx',gen(BODY_`idx'a) reverse base(0) label("body")
  local maxscore =`maxscore'+r(max) 
}
capture safedrop y3 
tempvar tmp
egen `tmp' = rowtotal(BODY_*a)
gen y3 =(`tmp')/(`maxscore')*100 
label variable y3 "身體功能量表(反)"
capture drop `tmp'
 
//Y4

local maxscore 0
local pcount 9
forvalues idx=1/`pcount' {
capture labdel C14_`idx', d(5)
recode C14_`idx' (5=.)
}

forvalues idx=1/`pcount' {
  qui myRecode C14_`idx',gen(IADL_`idx'a) reverse base(0) label("IADLs")
  local maxscore =`maxscore'+r(max) 
}
capture safedrop y4 
tempvar tmp
egen `tmp' = rowtotal(IADL_*a)
gen y4 =(`tmp')/(`maxscore')*100 
label variable y4 "工具性障礙(反)"
capture drop `tmp'
 

//Y5 
 
  qui myRecode B15,gen(living_a) reverse base(0) label("living")
  local maxscore = r(max) 
  gen y5 =(living_a)/(`maxscore')*100 
label variable y5 "居住狀態(反)"


//Y6
local maxscore 0 
local pcount 8
forvalues idx=1/`pcount' {
  
  qui myRecode F4_`idx',gen(commu_`idx'a) base(0) label("commu")
  local maxscore = `maxscore'+r(max)  
}
capture safedrop y6
tempvar tmp
egen `tmp' = rowtotal(commu_*a)
gen y6 =(`tmp')/(`maxscore')*100 
label variable y6 "社團活動(正向)"
capture drop `tmp'
 
forvalue idx=1/6{ 
ren y`idx' oy`idx' 
}




drop dise_*a
drop ADL_*a
drop BODY_*a
drop IADL_*a
drop living_a
drop commu_*a

//********************************
//new version
//******************************** 
//Y1 
local maxscore 0
local pcount 20
forvalues idx=1/`pcount' {
  qui myRecode C3_`idx',gen(dise_`idx'a) base(0) label("dise`idx'")
  local maxscore =`maxscore'+r(max) 
  
}

capture safedrop y1 

egen dise_o = rowtotal(dise_*a)
label variable dise_o  "原始慢性病個數"

gen y1 =(`maxscore'-dise_o)/(`maxscore')*100 
label variable y1 "慢性疾病個數(反)"

//y2


local maxscore 0
local pcount 6
forvalues idx=1/`pcount' {
  qui myRecode C16_`idx',gen(ADL_`idx'a) base(0) label("ADL`idx'")
  local maxscore =`maxscore'+r(max) 
}

capture safedrop y2 
egen adl_o = rowtotal(ADL_*a)
label variable adl_o "原始日常障礙"
gen y2 =(`maxscore'-adl_o)/(`maxscore')*100 
label variable y2 "日常障礙(反)"

  
 // Y3   身體功能量表(負向)   
// 沒困難,0-3 基底0
local maxscore 0
local pcount 10
forvalues idx=1/`pcount' {
  qui myRecode C13_`idx',gen(BODY_`idx'a) base(0) label("body`idx'")
  local maxscore =`maxscore'+r(max) 
}
capture safedrop y3 

egen body_o = rowtotal(BODY_*a)
label variable body_o "原始身體功能量表"
gen y3 =(`maxscore'-body_o)/(`maxscore')*100 
label variable y3 "身體功能量表(反)"

 
//y4


local maxscore 0
local pcount 9
forvalues idx=1/`pcount' {
capture labdel C14_`idx', d(5)
recode C14_`idx' (5=.)
}

forvalues idx=1/`pcount' {
  qui myRecode C14_`idx',gen(IADL_`idx'a)  base(0) label("IADLs`idx'")
  local maxscore =`maxscore'+r(max) 
}
capture safedrop y4 

egen iadl_o = rowtotal(IADL_*a)
label variable iadl_o "原始工具性障礙"
gen y4 =(`maxscore'-iadl_o)/(`maxscore')*100 
label variable y4 "工具性障礙(反)"

 //y5
  qui myRecode B15,gen(living_a) base(0) label("living")
  local maxscore = r(max) 
  gen living_o = living_a
  label variable living_o "原始居住狀態"
  gen y5 =(`maxscore'-living_a)/(`maxscore')*100 
label variable y5 "居住狀態(正向)"

//y6

local maxscore 0 
local pcount 8
forvalues idx=1/`pcount' {
  
  qui myRecode F4_`idx',gen(commu_`idx'a) base(0) label("commu`idx'")
  local maxscore = `maxscore'+r(max)  
}
capture safedrop y6

egen commu_o = rowtotal(commu_*a)
label variable commu_o "原始社團活動"
gen y6 =(commu_o)/(`maxscore')*100 
label variable y6 "社團活動(正向)"

forvalues idx=1/6{
ren y`idx' ny`idx'
}
  
  
//********************************
// check
//********************************


forvalues idx=1/6{
tab2 oy`idx' ny`idx'
}