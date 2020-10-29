global outposix "out_first92Y_v1"

// 清除報表: 殺掉暫存檔 
local xfiles : dir report files "${outposix}_*.*"

foreach fn of local xfiles {
 erase report/`fn'
}

adopath + "D:\Activity\elderman\utils"
set linesize 255

//use ../data/tlsa03o_de,clear
decodeds using ../data/tlsa03y_de,gen(../tmp/xx.dta)
use ../tmp/xx.dta,clear
qui ds
global ovar `r(varlist)'


local maxscore 0
local pcount 15
forvalues idx=1/`pcount' {
  qui myRecode2 C3_`idx',gen(dise_`idx'a) base(0) label("dise`idx'")
  local maxscore =`maxscore'+r(max) 
  
}

capture safedrop y1 


egen dise_o = rowtotal(dise_*a)
label variable dise_o  "原始慢性病個數"

gen y1 =(`maxscore'-dise_o)/(`maxscore')*100 
label variable y1 "慢性疾病個數(反)"

disp "最大值  `maxscore'"
forvalues idx=1/`pcount' {
tab2 dise_`idx'a C3_`idx'
}
tab2 dise_o y1




local maxscore 0
local pcount 6
forvalues idx=1/`pcount' {
  qui myRecode2 C25`idx',gen(ADL_`idx'a) base(0) label("ADL`idx'")
  local maxscore =`maxscore'+r(max) 
}

capture safedrop y2 
egen adl_o = rowtotal(ADL_*a)
label variable adl_o "原始日常障礙"
gen y2 =(`maxscore'-adl_o)/(`maxscore')*100 
label variable y2 "日常障礙(反)"

disp "最大值  `maxscore'"
sum adl_o
forvalues idx=1/`pcount' {
tab2 ADL_`idx'a C25`idx',missing
}
tab2 adl_o y2
 

// Y3   身體功能量表(負向)   
// 沒困難,0-3 基底0
local maxscore 0
local pcount 9
forvalues idx=1/`pcount' {
  qui myRecode2 C23`idx',gen(BODY_`idx'a) base(0) label("body`idx'")
  local maxscore =`maxscore'+r(max) 
}
capture safedrop y3 

egen body_o = rowtotal(BODY_*a)
label variable body_o "原始身體功能量表"
gen y3 =(`maxscore'-body_o)/(`maxscore')*100 
label variable y3 "身體功能量表(反)"

disp "最大值  `maxscore'"
sum body_o
forvalues idx=1/`pcount' {
tab2 BODY_`idx'a C23`idx',missing
}

tab2 body_o y3


local maxscore 0
local pcount 6

forvalues idx=1/`pcount' {
  qui myRecode2 C24`idx',gen(IADL_`idx'a)  base(0) label("IADLs`idx'")
  local maxscore =`maxscore'+r(max) 
}
capture safedrop y4 

egen iadl_o = rowtotal(IADL_*a)
label variable iadl_o "原始工具性障礙"
gen y4 =(`maxscore'-iadl_o)/(`maxscore')*100 
label variable y4 "工具性障礙(反)"

disp "最大值  `maxscore'"
sum iadl_o
forvalues idx=1/`pcount' {
tab2 IADL_`idx'a C24`idx',missing
}
tab2 iadl_o y4
 

  qui myRecode2 B24,gen(living_a) base(0) label("living")
  local maxscore = r(max) 
  gen living_o = living_a
  label variable living_o "原始居住狀態"
  gen y5 =(`maxscore'-living_a)/(`maxscore')*100 
label variable y5 "居住狀態(反向)"

tab2 living_o B24,missing
tab2 y5 B24,missing



local maxscore 0 
local pcount 8
forvalues idx=1/`pcount' {
  
  qui myRecode2 F4`idx',gen(commu_`idx'a) base(0) label("commu`idx'")
  local maxscore = `maxscore'+r(max)  
}
capture safedrop y6

egen commu_o = rowtotal(commu_*a)
label variable commu_o "原始社團活動"
gen y6 =(commu_o)/(`maxscore')*100 
label variable y6 "社團活動(正向)"

disp "最大值  `maxscore'"
sum commu_o
forvalues idx=1/`pcount' {
tab2 commu_`idx'a F4`idx',missing
}



local maxscore = 0
foreach idx in 1 2 3 4 6 10 {

  qui myRecode2 C44`idx',gen(life_`idx'a) base(0)
  local maxscore = `maxscore'+r(max)  
}
// 反向
foreach idx in 5 7 8 9 {
  qui myRecode2 C44`idx',gen(life_`idx'a) base(0) reverse
  local maxscore = `maxscore'+r(max)  
}
egen life = rowtotal(life_*a)
label variable life "生活滿意度"
gen life100 =(life-0)/(10-0)*100

label variable life100 "生活滿意度(100)"

disp "最大值  `maxscore'"
sum life life100
forvalues idx = 1/10 {
  tab2 life_`idx'a C44`idx',missing
}

 
  qui myRecode2 C1,gen(heal) base(0) reverse
  local maxscore =r(max)
  return list
  

  gen heal100 =(heal-0)/(`maxscore')*100 //82年  
  label variable heal "自覺健康"
  label variable heal100 "自覺健康(100)"

  disp "最大值  `maxscore'"
  tab2 C1 heal,missing

//## x3 自覺經濟狀況
  qui myRecode2 G5,gen(money) base(0) reverse
  local maxscore =r(max)
  return list
  

  //recode G3 (1=5)(2=4)(3=3)(4=2)(5=1)(nonmissing=.) ,gen(money)
  gen money100 =(money-0)/(`maxscore')*100 //82年  

  label variable money "自覺經濟"
  label variable money100 "自覺經濟(100)"
  
  disp "最大值  `maxscore'"
  sum money money100
  tab2 G5 money,missing
   
capture safedrop child
myRecode2 B1_NEW,gen(child) base(0)
 
 label variable child "子女數"
 
 tab2 child B1_NEW
// 宗教信仰 
  qui myRecode2 F6,gen(relin1) 
  return list
  
 
  recode relin1 (1=0)(2/8=1),gen(relin)
  label variable relin "宗教"
  label define relin 0 "無宗教" 1 "有宗教"
  label value relin relin
  capture safedrop relin1
  tab2 relin F6,missing

  qui myRecode2 G8A21,gen(incom) 
  label variable incom "收入"
  recode incom (9/max=9)
  tab2 G8A21 incom,missing 



capture safedrop incsrc1
gen incsrc1 = G1_1_NEW 
//xxxx
//replace incsrc1=. if incsrc1==23 | incsrc1==24 //主要經濟來源未知或不詳
//recode incsrc1 (1/2=1)(3/max=0),gen(incsrc)
//replace incsrc1="" if incsrc1==23 | incsrc1==24 //主要經濟來源未知或不詳
replace incsrc1="" if inlist(incsrc1,"99","888","998","999")
sencode incsrc1,gsort(incsrc1) replace
recode incsrc1 (1/2=1)(nonmissing=0),gen(incsrc)
label variable incsrc ""
label variable incsrc "經濟來源"
label define incsrc 0 "非本人或配偶" 1 "本人或配偶"
label value incsrc incsrc
safedrop incsrc1

tab2 incsrc G1_1_NEW


destring A13,replace
recode A13 (1=1)(2/5=0)(nonmissing=.),gen(mar)
label variable mar ""
label variable mar "是否單身"
label define mar 0 "單身" 1 "非單身"
label value mar mar

tab2 A13 mar,missing


capture drop taba

myRecode2 C33,gen(taba) base(0)
label variable taba ""
label variable taba "抽菸"
label define taba 0 "不抽菸" 1 "抽菸"
label value taba taba

tab2 taba C33

  
tab C27
myRecode2 C27,gen(alco) base(0)


local vname "alco"
label variable `vname' ""
label variable `vname' "喝酒"
label define `vname' 0 "不喝酒" 1 "喝酒"
label value `vname' `vname'

tab2 alco C27

tab C28
destring C28,gen(bet)


local vname "bet"
label variable `vname' ""
label variable `vname' "檳榔"
label define `vname' 0 "不吃檳榔" 1 "吃檳榔"
label value `vname' `vname'


replace C29="" if C29=="5"
capture drop xx
sencode C29,gen(xx) gsort(C29)
recode xx (1=0)(2/5=1)(nonmissing=.),gen(spor)
tab2 C29 spor


local vname "spor"
label variable `vname' ""
label variable `vname' "運動"
label define `vname' 0 "不運動" 1 "運動"
label value `vname' `vname'

tab C34
sencode C34,replace gsort(C34)
recode C34 (1=0)(2=1)(nonmissing=.),gen(exam_year)

local vname "exam_year"
label variable `vname' ""
label variable `vname' "3年內曾健檢"
label define `vname' 0 "沒有健檢" 1 "有健檢"
label value `vname' `vname'

tab2 C34 exam_year,missing

capture safedrop wesmed
//decode C20C,gen(wesmed)
gen wesmed = C14C
replace wesmed="0" if C14B=="0"
replace wesmed="" if inlist(wesmed,"87","88","89","96", "97","98","99","8888","9998") | inlist(wesmed,"91")
//sencode wesmed,replace gsort(wesmed)
destring wesmed,replace
//C14B回答1:沒去過

tab2 wesmed C14C




//處理
local maxscore 0
local pcount =17-10+1
foreach idx in 10 11 12 13 14 15 16 17 {
  qui myRecode2 D`idx',gen(fami_`idx'a) base(0) reverse label("情緒支持")
  local maxscore =`maxscore'+r(max)
  tab2 fami_`idx'a D`idx',missing
}



egen fami = rowtotal(fami_*a)
gen fami100 =(fami-0)/(`maxscore')*100
  label variable fami "情緒支持"
  label variable fami100 "情緒支持(100)"

disp "最大值  `maxscore'"
sum fami fami100

 

destring B22AA,replace
gen alone=B22AA
label define alone 0 "非獨居" 1 "獨居"
label value alone alone
local maxscore 0
local pcount =11
foreach  idx in 1 2 3 5 6 7 8  { 
  qui myRecode2 C43`idx',gen(depre_`idx'a) base(0)  label("抑鬱指數")
  local maxscore = `maxscore'+r(max)
  tab2 depre_`idx'a C43`idx',missing
}
foreach  idx in 4 9 10 { 
  qui myRecode2 C43`idx',gen(depre_`idx'a) reverse base(0)  label("抑鬱指數")
  local maxscore = `maxscore'+r(max)
  tab2 depre_`idx'a C43`idx',missing
}


egen depre = rowtotal(depre*a)
gen depre100 =(depre-0)/(`maxscore'-0)*100 
label variable depre "抑鬱指數"
label variable depre100 "抑鬱指數(100)"

disp "最大值  `maxscore'"
sum depre depre100


//work1v3
local ovar1 ${ovar}
local kvar qtype ser_no4
local ovar1 :list ovar1 - kvar
disp "`ovar1'"
foreach item in `ovar1' {
  safedrop `item'
}




merge 1:1 qtype ser_no4 using ../data/bkgrd2003y_de,keepusing(SEX AGE_2003 EDUC_DE)
drop if _merge==2
//年齡
rename AGE_2003 age92
tab age92  //編號1到8
label variable age92 "年齡"

//性別
recode SEX (1=0)(2=1),gen(sex)
safedrop SEX

//教育程度

capture drop educ
gen educ=EDUC_DE
replace educ=. if educ== 8  //字串版:98-99
replace educ=educ-1
capture label drop educ
label define educ 0 "不識字" 1 "小學" 2 "初中" 3 "高職" 4 "大學" 5 "識字" 6 "空大"
label value educ educ
label variable educ "教育程度"

safedrop _merge

save ../transfer/elder92Y,replace

