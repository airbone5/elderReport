---
title: "合併和檢查92年"
author: "lin"
date: "11 九月, 2020, 13:46"
header-includes:
- \usepackage{xeCJK}
- \setCJKmainfont{標楷體}
output:
  html_document:  
    toc: yes
    toc_float:
      collapsed: false
      smooth_scroll: false    
    df_print: paged
    highlight: tango 
    keep_md: true   
  word_document:
    toc: yes
  pdf_document: 
    latex_engine: xelatex 
    toc: yes
knit:   myknit    
---




  


# 檢查



## 副程式


 subrouting 
combinOldNew92.do
 

```stata  
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

``` 

- 內容備份
```stata
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
safedroplist life100 heal100 money100 fami100 depre100



```

- checklevel.ado 檢查兩個檔案的每個變數的level 是不是相等,還有內容是不是一樣。  


 subrouting 
../utils/checklevel.ado
 

```stata  
capture program drop checklevel
program  checklevel
//問題:現在有兩個欄位,一個是主要欄位,一個是分類欄位,想要知道crosstab
syntax varname ,by(varlist)
qui levelsof `varlist' if `by'==0
local ncnt=r(r)
local nlevels = "`r(levels)'"

qui levelsof `varlist' if `by'==1
local ocnt=r(r)
local olevels = "`r(levels)'"

local rst 0
if `ncnt'!=`ocnt' {
  disp in red "`varlist' 個數不相等" 
  local rst 1
} 
else {
   if "`olevels'" !="`nlevels'" {
      disp in red "內含不相等"
	  local rst 1
   }
   
}
  
if `rst'==1 {
	  disp in red "new: `nlevels'"
	  disp in red "old: `olevels'"
}  


end

``` 


## 檢查測試


```
 do combinOldNew92.do   //合併副程式
 eststo clear
  estpost tabstat y?, by(qsrc) statistics(count min max mean)  columns(statistics) 
  esttab ,  label 
//genfilename "$outposix",post(.html) pre("report/") autoinc 
//esttab using "`r(fn)'", cells("count(fmt(%9.1f)) mean(fmt(%9.1f)) ") label mtitle   html wide

//check Y1: C3_1 to C3_20  =>dise_*a
/*
unab vv:C3_*  
foreach item in `vv' {
disp "`item'"
checklevel `item',by(qsrc)
} 
*/
unab vv:dise_*a
foreach item in `vv' {
disp "`item'"
checklevel `item',by(qsrc)
} 

//check Y2: C16_* =>ADL
unab vv:C16_*  
foreach item in `vv' {
disp "`item'"
checklevel `item',by(qsrc)
} 

unab vv:ADL_*a
foreach item in `vv' {
disp "`item'"
checklevel `item',by(qsrc)
} 
//check Y3: C13_*  ==>BODY_*a
/*
unab vv:C13_*
foreach item in `vv' {
disp as text "`item'"
checklevel `item',by(qsrc)
} 
*/
unab vv:BODY_*a
foreach item in `vv' {
disp as text "`item'"
checklevel `item',by(qsrc)
} 

//check Y4: C14_*  ==>IADL_*a
/*
C14_2,C14_8 不一樣,因為有的是選項4:不識字,但是很奇怪,其他選項又識字
*/
unab vv:IADL_*a
foreach item in `vv' {
disp as text "`item'"
checklevel `item',by(qsrc)
} 
//Y5: B15 =>living_a
//checklevel B15,by(qsrc)
checklevel living_a,by(qsrc)
//Y6
unab vv:commu_*a
foreach item in `vv' {
disp as text "`item'"
checklevel `item',by(qsrc)
}

//x1:生活滿意度

unab vv:life_*a
foreach item in `vv' {
disp as text "`item'"
checklevel `item',by(qsrc)
}


//x2=>heal
checklevel heal,by(qsrc)
//x3=money, G3
checklevel G3,by(qsrc)
checklevel money,by(qsrc)

//年齡跳過

//現存子女數
//宗教信仰F7==>relign,relign1
//年收入G5_1==>incom
checklevel incom,by(qsrc)
//主要經濟來源  incsrc
checklevel incsrc,by(qsrc)
//婚姻
checklevel mar,by(qsrc)
//抽菸喝酒檳榔跳過
//健康檢查
checklevel exam_year,by(qsrc)
//門診次數C20C->wesmed 如數照路
checklevel wesmed,by(qsrc)

//fami_`idx'a

unab vv:fami_*a
foreach item in `vv' {
disp as text "`item'"
checklevel `item',by(qsrc)
}


//depre_`idx'a
unab vv:depre_*a
foreach item in `vv' {
disp as text "`item'"
checklevel `item',by(qsrc)
}

```

# 合併產生Y,存檔

  
- 副程式說明:  
  * combinOldNew.do 合併新舊世代,但是部存檔  
  * genModelY.do 產生模型需要的Y變數  


 subrouting 
combinOldNew92.do
 

```stata  
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

``` 

 subrouting 
genModelY.do
 

```stata  

//暫時的Y變數,要給模型Y用的
forvalues idx=1/6 {
  tobin y`idx',gen("y`idx'_eqg_me") mean  eqg
  tobin y`idx',gen("y`idx'_g_me") mean  g  
  tobin y`idx',gen("y`idx'_eqg_md") p50  eqg
  tobin y`idx',gen("y`idx'_g_md") p50  g  
  tobin y`idx',gen("y`idx'_eqg_umd") up50  eqg  
  tobin y`idx',gen("y`idx'_g_umd") up50  g  
}


//產生logistic 模型用的y :my_1- my_6
local idx 1
foreach sep in me md umd{
  foreach opr in eqg g{
    capture safedrop my_`idx'
    local ylabel "`=cond("`opr'"=="eqg","大等","大於")'`=cond("`sep'"=="me","平均",cond("`sep'"=="md","中間","獨中間"))'"
    modelbin y1_`opr'_`sep' y2_`opr'_`sep' y3_`opr'_`sep' y4_`opr'_`sep' y5_`opr'_`sep' y6_`opr'_`sep',gen(my_`idx') label("`ylabel'") 
   disp "`ylabel'"
    local ++idx
  }
}
  
//總和y,和其產生的二元my_0
gen y=y1+y2+y3+y4+y5+y6
label variable y "六項總和"

 
  tobin y,gen("myt_1") mean  eqg label("總和eqg_me")
  tobin y,gen("myt_2") mean  g  label("總和g_me")
  tobin y,gen("myt_3") p50  eqg label("總和eqg_md")
  tobin y,gen("myt_4") p50  g label("總和g_md")  
  tobin y,gen("myt_5") up50  eqg  label("總和eqg_umd")
  tobin y,gen("myt_6") up50  g  label("總和g_umd")

``` 


```stata
do combinOldNew92.do
do genModelY.do
save ../transfer/elder92,replace
```

```
 . do combinOldNew92.do

. // 合併新舊世代成為新資料表 elder92
. 
. global outposix "out_combin_92"

. use ../transfer/elder92Y,clear

. quietly append using ../transfer/elder92R,gen(qsrc)

. 
. lab define qsrc 0 "92新世代" 1 "92舊世代"

. label value qsrc qsrc

. tab2  qtype qsrc

-> tabulation of qtype by qsrc  

           |         qsrc
     qtype |  92新世代   92舊世代 |     Total
-----------+----------------------+----------
         A |         0      2,035 |     2,035 
         B |         0      1,743 |     1,743 
         C |     1,599          0 |     1,599 
-----------+----------------------+----------
     Total |     1,599      3,778 |     5,377 

. 
. // "年齡" 處理
. ren age92 age92s

. encode age92s,gen(age92)

. tab age92

     字串年 |
         齡 |      Freq.     Percent        Cum.
------------+-----------------------------------
      50-54 |      1,248       23.21       23.21
      55-59 |        688       12.80       36.01
      60-64 |        690       12.83       48.84
      65-69 |        572       10.64       59.48
      70-74 |        588       10.94       70.41
      75-79 |        879       16.35       86.76
      80-84 |        477        8.87       95.63
        85+ |        235        4.37      100.00
------------+-----------------------------------
      Total |      5,377      100.00

. tab age92,nolab

     字串年 |
         齡 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,248       23.21       23.21
          2 |        688       12.80       36.01
          3 |        690       12.83       48.84
          4 |        572       10.64       59.48
          5 |        588       10.94       70.41
          6 |        879       16.35       86.76
          7 |        477        8.87       95.63
          8 |        235        4.37      100.00
------------+-----------------------------------
      Total |      5,377      100.00

. drop age92s

. 
. //性別
. tab2 sex qsrc

-> tabulation of sex by qsrc  

 RECODE of |         qsrc
       SEX |  92新世代   92舊世代 |     Total
-----------+----------------------+----------
         0 |       813      1,948 |     2,761 
         1 |       786      1,830 |     2,616 
-----------+----------------------+----------
     Total |     1,599      3,778 |     5,377 

. label variable sex ""

. label variable sex "性別"

. label define sex 0 "男" 1 "女"

. label value sex sex

. 
. 
. label drop educ

. label define educ 0 "不識字" 1 "小學" 2 "初中" 3 "高職" 4 "大學" 5 "識字" 6 "空大"

. label value educ educ

. label variable educ "教育程度"

. tab2 educ qsrc

-> tabulation of educ by qsrc  

    教育程 |         qsrc
        度 |  92新世代   92舊世代 |     Total
-----------+----------------------+----------
    不識字 |        47      1,155 |     1,202 
      小學 |       753      1,512 |     2,265 
      初中 |       292        290 |       582 
      高職 |       247        223 |       470 
      大學 |       231        373 |       604 
      識字 |        24        225 |       249 
      空大 |         5          0 |         5 
-----------+----------------------+----------
     Total |     1,599      3,778 |     5,377 

. 
. //孩子數目
. tab2 child qsrc

-> tabulation of child by qsrc  

              |         qsrc
       子女數 |  92新世代   92舊世代 |     Total
--------------+----------------------+----------
       00_0人 |        80        167 |       247 
       01_1人 |        84        109 |       193 
       02_2人 |       464        417 |       881 
       03_3人 |       586        774 |     1,360 
       04_4人 |       282        859 |     1,141 
   05_5人以上 |       103        667 |       770 
            6 |         0        430 |       430 
            7 |         0        355 |       355 
--------------+----------------------+----------
        Total |     1,599      3,778 |     5,377 

. capture safedrop cx

. recode child (6/7=5),gen(cx)
(785 differences between child and cx)

. safedrop child

. ren cx child

. capture label drop child

. label define child 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+"

. label value child child

. label variable child "子女數"

. tab2 child qsrc

-> tabulation of child by qsrc  

           |         qsrc
    子女數 |  92新世代   92舊世代 |     Total
-----------+----------------------+----------
         0 |        80        167 |       247 
         1 |        84        109 |       193 
         2 |       464        417 |       881 
         3 |       586        774 |     1,360 
         4 |       282        859 |     1,141 
        5+ |       103      1,452 |     1,555 
-----------+----------------------+----------
     Total |     1,599      3,778 |     5,377 

. // 補上
. label variable wesmed "西醫次數"

. 
. capture safedrop tmp

. ren incom tmp

. recode tmp (10/max=9),gen(incom)
(27 differences between tmp and incom)

. tab2 incom qsrc

-> tabulation of incom by qsrc  

 RECODE of |         qsrc
       tmp |  92新世代   92舊世代 |     Total
-----------+----------------------+----------
         1 |        13         22 |        35 
         2 |        56        195 |       251 
         3 |        93        375 |       468 
         4 |       152        395 |       547 
         5 |       213        406 |       619 
         6 |       167        275 |       442 
         7 |        73        144 |       217 
         8 |        47         50 |        97 
         9 |        18         32 |        50 
-----------+----------------------+----------
     Total |       832      1,894 |     2,726 

. 
. label define incom 1 "10-" 2 "10~30-" 3 "30~50-" 4 "50~70-" 5 "70~100-" 6 "100~150-" 7 "150~200-" 8 "200~300-" 9 "300+"

. label value incom incom

. tab2 incom qsrc

-> tabulation of incom by qsrc  

 RECODE of |         qsrc
       tmp |  92新世代   92舊世代 |     Total
-----------+----------------------+----------
       10- |        13         22 |        35 
    10~30- |        56        195 |       251 
    30~50- |        93        375 |       468 
    50~70- |       152        395 |       547 
   70~100- |       213        406 |       619 
  100~150- |       167        275 |       442 
  150~200- |        73        144 |       217 
  200~300- |        47         50 |        97 
      300+ |        18         32 |        50 
-----------+----------------------+----------
     Total |       832      1,894 |     2,726 

. 
. //safedroplist AGE_2015_AGE_NEW EDUC_NEW QTYPE SER_NO4 SEX
. //safedroplist life100 heal100 money100 fami100 depre100
. 
. do genModelY.do

. 
. //暫時的Y變數,要給模型Y用的
. forvalues idx=1/6 {
  2.   tobin y`idx',gen("y`idx'_eqg_me") mean  eqg
  3.   tobin y`idx',gen("y`idx'_g_me") mean  g  
  4.   tobin y`idx',gen("y`idx'_eqg_md") p50  eqg
  5.   tobin y`idx',gen("y`idx'_g_md") p50  g  
  6.   tobin y`idx',gen("y`idx'_eqg_umd") up50  eqg  
  7.   tobin y`idx',gen("y`idx'_g_umd") up50  g  
  8. }

. 
. 
. //產生logistic 模型用的y :my_1- my_6
. local idx 1

. foreach sep in me md umd{
  2.   foreach opr in eqg g{
  3.     capture safedrop my_`idx'
  4.     local ylabel "`=cond("`opr'"=="eqg","大等","大於")'`=cond("`sep'"=="me","平均",cond("`sep'"=="md","中間","獨中間"))'"
  5.     modelbin y1_`opr'_`sep' y2_`opr'_`sep' y3_`opr'_`sep' y4_`opr'_`sep' y5_`opr'_`sep' y6_`opr'_`sep',gen(my_`idx') label("`ylabel'") 
  6.    disp "`ylabel'"
  7.     local ++idx
  8.   }
  9. }
(my_1: 5377 changes made)
(556 real changes made)
大等平均
(my_2: 5377 changes made)
(556 real changes made)
大於平均
(my_3: 5377 changes made)
(1,943 real changes made)
大等中間
(my_4: 5377 changes made)
(0 real changes made)
大於中間
(my_5: 5377 changes made)
(74 real changes made)
大等獨中間
(my_6: 5377 changes made)
(70 real changes made)
大於獨中間

.   
. //總和y,和其產生的二元my_0
. gen y=y1+y2+y3+y4+y5+y6
(325 missing values generated)

. label variable y "六項總和"

. 
.  
.   tobin y,gen("myt_1") mean  eqg label("總和eqg_me")

.   tobin y,gen("myt_2") mean  g  label("總和g_me")

.   tobin y,gen("myt_3") p50  eqg label("總和eqg_md")

.   tobin y,gen("myt_4") p50  g label("總和g_md")  

.   tobin y,gen("myt_5") up50  eqg  label("總和eqg_umd")

.   tobin y,gen("myt_6") up50  g  label("總和g_umd")

. 
end of do-file

. save ../transfer/elder92,replace
file ../transfer/elder92.dta saved

. 
end of do-file
```


# 所有程式碼

```stata  
global outposix "out_combin92_v1"
// 清除報表: 殺掉暫存檔 
local xfiles : dir report files "${outposix}_*.*"

foreach fn of local xfiles {
 erase report/`fn'
}

adopath + "D:\Activity\elderman\utils"
set linesize 255
do combinOldNew92.do
do genModelY.do
save ../transfer/elder92,replace

``` 
