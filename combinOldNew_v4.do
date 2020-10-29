// 合併新舊世代成為新資料表 elder104
// 為了版本一次,直接變成第4版
global outposix "out_combin_v4"
use ../transfer/work_old_v4,clear
quietly append using ../transfer/work_new_v4,gen(qsrc)
recode qsrc (1=0)(0=1)
//recode QTYPE (1/3=1) (4=0),gen(qsrc)
lab define qsrc 0 "新世代" 1 "舊世代"
label value qsrc qsrc
tab2  qtype qsrc

merge 1:1 qtype ser_no4 using ../transfer/bkgr104
drop _merge
label variable age104 "年齡"

capture safedrop sex
recode SEX (1=0)(2=1),gen(sex)
label variable sex "性別"
label define sex 0 "男" 1 "女"
label value sex sex
tab2 sex SEX

replace educ=. if educ== 8  //98-99
replace educ=educ-1
label drop educ
label define educ 0 "不識字" 1 "小學" 2 "初中" 3 "高職" 4 "大學" 5 "識字" 6 "空大"
label value educ educ
label variable educ "教育程度"

//孩子數目
label define child 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+"
label value child child
label variable child "子女數"
gen child5 =0 if child!=.
replace child5 =1 if child==5
label variable child5 "小孩數目大於5"

// 補上
label variable wesmed "西醫次數"

label define incom 1 "10-" 2 "10~30-" 3 "30~50-" 4 "50~70-" 5 "70~100-" 6 "100~150-" 7 "150~200-" 8 "200~300-" 9 "300+"
label value incom incom


safedroplist AGE_2015_AGE_NEW EDUC_NEW QTYPE SER_NO4 SEX
//safedroplist life100 heal100 money100 fami100 depre100

