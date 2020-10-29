// 合併新舊世代成為新資料表 elder92

global outposix "out_combin_92"
use ../transfer/elder92Y,clear
quietly append using ../transfer/elder92R,gen(qsrc)

lab define qsrc 0 "92新世代" 1 "92舊世代"
label value qsrc qsrc
tab2  qtype qsrc

// "年齡" 處理
ren age92 age92s
encode age92s,gen(age92)
tab age92
tab age92,nolab
drop age92s

//性別
tab2 sex qsrc
label variable sex ""
label variable sex "性別"
label define sex 0 "男" 1 "女"
label value sex sex


label drop educ
label define educ 0 "不識字" 1 "小學" 2 "初中" 3 "高職" 4 "大學" 5 "識字" 6 "空大"
label value educ educ
label variable educ "教育程度"
tab2 educ qsrc

//孩子數目
tab2 child qsrc
capture safedrop cx
recode child (6/7=5),gen(cx)
safedrop child
ren cx child
capture label drop child
label define child 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+"
label value child child
label variable child "子女數"
tab2 child qsrc
// 補上
label variable wesmed "西醫次數"

capture safedrop tmp
ren incom tmp
recode tmp (10/max=9),gen(incom)
tab2 incom qsrc

label define incom 1 "10-" 2 "10~30-" 3 "30~50-" 4 "50~70-" 5 "70~100-" 6 "100~150-" 7 "150~200-" 8 "200~300-" 9 "300+"
label value incom incom
tab2 incom qsrc

//safedroplist AGE_2015_AGE_NEW EDUC_NEW QTYPE SER_NO4 SEX
//safedroplist life100 heal100 money100 fami100 depre100

