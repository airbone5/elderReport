---
title: "處理變數 v3.2"
author: "lin"
date: "02 九月, 2020, 13:43"
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
combinOldNew_v2.do
 

```stata  
// 合併新舊世代成為新資料表 elder104
global outposix "out_combin"
use ../transfer/work_old_v32,clear
quietly append using ../transfer/work_new_v32,gen(qsrc)
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

- 內容備份
```stata
// 合併新舊世代成為新資料表 elder104
global outposix "out_combin"
use ../transfer/work_old_v32,clear
quietly append using ../transfer/work_new_v32,gen(qsrc)
recode qsrc (1=0)(0=1)
//recode QTYPE (1/3=1) (4=0),gen(qsrc)
lab define qsrc 0 "新世代" 1 "舊世代"
label value qsrc qsrc
tab2  qtype qsrc

merge 1:1 qtype ser_no4 using ../transfer/bkgr104
drop _merge

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
 .  do combinOldNew_v2.do   //合併副程式

. // 合併新舊世代成為新資料表 elder104
. global outposix "out_combin"

. use ../transfer/work_old_v32,clear

. quietly append using ../transfer/work_new_v32,gen(qsrc)

. recode qsrc (1=0)(0=1)
(qsrc: 8300 changes made)

. //recode QTYPE (1/3=1) (4=0),gen(qsrc)
. lab define qsrc 0 "新世代" 1 "舊世代"

. label value qsrc qsrc

. tab2  qtype qsrc

-> tabulation of qtype by qsrc  

           |         qsrc
     qtype |    新世代     舊世代 |     Total
-----------+----------------------+----------
         A |         0      1,346 |     1,346 
         B |         0        449 |       449 
         C |         0      1,201 |     1,201 
         D |     5,304          0 |     5,304 
-----------+----------------------+----------
     Total |     5,304      2,996 |     8,300 

. 
. merge 1:1 qtype ser_no4 using ../transfer/bkgr104

    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             8,300  (_merge==3)
    -----------------------------------------

. drop _merge

. label variable age104 "年齡"

. 
. capture safedrop sex

. recode SEX (1=0)(2=1),gen(sex)
(8300 differences between SEX and sex)

. label variable sex "性別"

. label define sex 0 "男" 1 "女"

. label value sex sex

. tab2 sex SEX

-> tabulation of sex by SEX  

           |          SEX
      性別 |         1          2 |     Total
-----------+----------------------+----------
        男 |     4,040          0 |     4,040 
        女 |         0      4,260 |     4,260 
-----------+----------------------+----------
     Total |     4,040      4,260 |     8,300 

. 
. replace educ=. if educ== 8  //98-99
(13 real changes made, 13 to missing)

. replace educ=educ-1
(8,287 real changes made)

. label drop educ

. label define educ 0 "不識字" 1 "小學" 2 "初中" 3 "高職" 4 "大學" 5 "識字" 6 "空大" 

. label value educ educ

. label variable educ "教育程度"

. 
. //孩子數目
. label define child 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+"

. label value child child

. label variable child "子女數"

. gen child5 =0 if child!=.
(3 missing values generated)

. replace child5 =1 if child==5
(1,139 real changes made)

. label variable child5 "小孩數目大於5"

. 
. // 補上
. label variable wesmed "西醫次數"

. 
. label define incom 1 "10-" 2 "10~30-" 3 "30~50-" 4 "50~70-" 5 "70~100-" 6 "100~150-" 7 "150~200-" 8 "200~300-" 9 "300+"

. label value incom incom

. 
. 
. safedroplist AGE_2015_AGE_NEW EDUC_NEW QTYPE SER_NO4 SEX

. safedroplist life100 heal100 money100 fami100 depre100

. 
.  eststo clear

.   estpost tabstat y?, by(qsrc) statistics(count min max mean)  columns(statistics) 

Summary statistics: count min max mean
     for variables: y1 y2 y3 y4 y5 y6
  by categories of: qsrc

        qsrc |  e(count)     e(min)     e(max)    e(mean) 
-------------+--------------------------------------------
新世代       |                                            
          y1 |      5304         35        100   90.41384 
          y2 |      5304          0        100   95.83019 
          y3 |      5304          0        100   88.68087 
          y4 |      5304          0        100   91.99556 
          y5 |      5008          0        100   78.21985 
          y6 |      5304          0        100    7.79129 
-------------+--------------------------------------------
舊世代       |                                            
          y1 |      2996         20        100   86.91422 
          y2 |      2996          0        100   91.05289 
          y3 |      2996          0        100   79.32465 
          y4 |      2996          0        100   83.80433 
          y5 |      2685          0        100   77.81192 
          y6 |      2996          0       87.5   8.548899 
-------------+--------------------------------------------
Total        |                                            
          y1 |      8300         20        100    89.1506 
          y2 |      8300          0        100   94.10576 
          y3 |      8300          0        100   85.30361 
          y4 |      8300          0        100   89.03882 
          y5 |      7693          0        100   78.07747 
          y6 |      8300          0        100   8.064759 

.   esttab ,  label 

------------------------------------
                              (1)   
                                    
------------------------------------
------------------------------------
Observations                 8300   
------------------------------------
t statistics in parentheses
* p<0.05, ** p<0.01, *** p<0.001

. //genfilename "$outposix",post(.html) pre("report/") autoinc 
. //esttab using "`r(fn)'", cells("count(fmt(%9.1f)) mean(fmt(%9.1f)) ") label mtitle   html wide
. 
. //check Y1: C3_1 to C3_20  =>dise_*a
. /*
> unab vv:C3_*  
> foreach item in `vv' {
> disp "`item'"
> checklevel `item',by(qsrc)
> } 
> */
. unab vv:dise_*a

. foreach item in `vv' {
  2. disp "`item'"
  3. checklevel `item',by(qsrc)
  4. } 
dise_1a
dise_2a
dise_3a
dise_4a
dise_5a
dise_6a
dise_7a
dise_8a
dise_9a
dise_10a
dise_11a
dise_12a
dise_13a
dise_14a
dise_15a
dise_16a
dise_17a
dise_18a
dise_19a
dise_20a

. 
. //check Y2: C16_* =>ADL
. unab vv:C16_*  
variable C16_* not found
r(111);

end of do-file
r(111);
```

# 合併產生Y,存檔

  
- 副程式說明:  
  * combinOldNew.do 合併新舊世代,但是部存檔  
  * genModelY.do 產生模型需要的Y變數  


 subrouting 
combinOldNew_v1.do
 

```stata  
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
do combinOldNew_v2.do
do genModelY.do
save ../transfer/elder104,replace
```

```
 . do combinOldNew_v2.do

. // 合併新舊世代成為新資料表 elder104
. global outposix "out_combin"

. use ../transfer/work_old_v32,clear

. quietly append using ../transfer/work_new_v32,gen(qsrc)

. recode qsrc (1=0)(0=1)
(qsrc: 8300 changes made)

. //recode QTYPE (1/3=1) (4=0),gen(qsrc)
. lab define qsrc 0 "新世代" 1 "舊世代"

. label value qsrc qsrc

. tab2  qtype qsrc

-> tabulation of qtype by qsrc  

           |         qsrc
     qtype |    新世代     舊世代 |     Total
-----------+----------------------+----------
         A |         0      1,346 |     1,346 
         B |         0        449 |       449 
         C |         0      1,201 |     1,201 
         D |     5,304          0 |     5,304 
-----------+----------------------+----------
     Total |     5,304      2,996 |     8,300 

. 
. merge 1:1 qtype ser_no4 using ../transfer/bkgr104

    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             8,300  (_merge==3)
    -----------------------------------------

. drop _merge

. label variable age104 "年齡"

. 
. capture safedrop sex

. recode SEX (1=0)(2=1),gen(sex)
(8300 differences between SEX and sex)

. label variable sex "性別"

. label define sex 0 "男" 1 "女"

. label value sex sex

. tab2 sex SEX

-> tabulation of sex by SEX  

           |          SEX
      性別 |         1          2 |     Total
-----------+----------------------+----------
        男 |     4,040          0 |     4,040 
        女 |         0      4,260 |     4,260 
-----------+----------------------+----------
     Total |     4,040      4,260 |     8,300 

. 
. replace educ=. if educ== 8  //98-99
(13 real changes made, 13 to missing)

. replace educ=educ-1
(8,287 real changes made)

. label drop educ

. label define educ 0 "不識字" 1 "小學" 2 "初中" 3 "高職" 4 "大學" 5 "識字" 6 "空大" 

. label value educ educ

. label variable educ "教育程度"

. 
. //孩子數目
. label define child 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+"

. label value child child

. label variable child "子女數"

. gen child5 =0 if child!=.
(3 missing values generated)

. replace child5 =1 if child==5
(1,139 real changes made)

. label variable child5 "小孩數目大於5"

. 
. // 補上
. label variable wesmed "西醫次數"

. 
. label define incom 1 "10-" 2 "10~30-" 3 "30~50-" 4 "50~70-" 5 "70~100-" 6 "100~150-" 7 "150~200-" 8 "200~300-" 9 "300+"

. label value incom incom

. 
. 
. safedroplist AGE_2015_AGE_NEW EDUC_NEW QTYPE SER_NO4 SEX

. safedroplist life100 heal100 money100 fami100 depre100

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
(my_1: 8300 changes made)
(616 real changes made)
大等平均
(my_2: 8300 changes made)
(616 real changes made)
大於平均
(my_3: 8300 changes made)
(3,050 real changes made)
大等中間
(my_4: 8300 changes made)
(0 real changes made)
大於中間
(my_5: 8300 changes made)
(194 real changes made)
大等獨中間
(my_6: 8300 changes made)
(58 real changes made)
大於獨中間

.   
. //總和y,和其產生的二元my_0
. gen y=y1+y2+y3+y4+y5+y6
(607 missing values generated)

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

. save ../transfer/elder104,replace
file ../transfer/elder104.dta saved

. 
end of do-file
```


# 所有程式碼

```stata  
global outposix "out_combin_v2"
// 清除報表: 殺掉暫存檔 
local xfiles : dir report files "${outposix}_*.*"

foreach fn of local xfiles {
 erase report/`fn'
}

adopath + "D:\Activity\elderman\utils"
set linesize 255
 do combinOldNew_v2.do   //合併副程式
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

do combinOldNew_v2.do
do genModelY.do
save ../transfer/elder104,replace

``` 
