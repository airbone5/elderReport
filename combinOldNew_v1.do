// 合併新舊世代成為新資料表 elder104
global outposix "out_combin"
use ../transfer/work_old_v3,clear
quietly append using ../transfer/work_new_v3

recode QTYPE (1/3=1) (4=0),gen(qsrc)
lab define qsrc 0 "新世代" 1 "舊世代"
label value qsrc qsrc

replace age104=age104+2 if qsrc==1
capture label drop age104
label define age104 1 "50-54" 2 "55-59" 3 "60-64" 4 "65-69" 5 "70-74" 6 "75-79" 7 "80-84" 8 "85+"
label  value age104 age104

