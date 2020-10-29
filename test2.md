---
title: "新舊合併回歸  v1"
author: "lin"
date: "31 八月, 2020, 13:29"
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
    css: ["tableStyle.css"]
    highlight: pygments
    keep_md: true
  word_document:
    toc: yes
  pdf_document: 
    latex_engine: xelatex 
    toc: yes
knit:  (function (...) { 
  source('myknit.r'); 
  myknit(...) 
  })     
---
 


 
# 概要
 
```stata
sysuse auto
sum

```

```stata  
capture program drop modelbin
program modelbin
syntax varlist ,gen(string) label(string)
capture confirm variable `gen'
if _rc==0 {
disp "`gen' exist"
exit 1
}
tempvar tmp

egen `gen'= anymatch(`varlist'),values(0)
recode `gen' (0=.)(1=0)
egen `tmp'=rowtotal(`varlist')
replace `gen'=1 if `tmp'==6 
label variable `gen' "`label'"
end

``` 
 
# test 
```stata  
/*
總之就是根據不同的分類結果,顯示某個值得個數或平均
例如有分類結果 y1_1 y1_2(不是0就是1)
barClass y1,over(y1_*) on(mean)
根據不同的分類,計算y1 的平均
沒有ON這個選項,就是計算個數(預設)

*/ 
capture program drop barClass
program barClass
  syntax varname [,over(varlist) on(string)]
  //local fn "tmpx"
  if "`on'"=="" local cmd "count"
  else local cmd "`on'"
  tempfile fn
  foreach class in `over' {
   qui { 
    preserve 
    capture confirm file `fn'
	local ok=_rc

    collapse (`cmd') `varlist' ,by(`class') 

    rename `class' sep
    rename `varlist' `class'
	if `ok'==0 merge 1:1 sep using `fn' ,nogenerate noreport
     save `fn',replace
	restore
	}
  }	

  preserve 
  use `fn',clear
  local idx 1
  foreach item of local over {
   local legend `"`legend' label(`idx' "`cmd' of `item'") "'
   local ++idx
  }
  graph bar `over',over(sep) legend( `legend') blabel(bar) 
  //graph bar `over',over(sep)
  restore

 
end

``` 
 


```stata
sysuse auto
sum foreign
```

```


. sysuse a(1978 Automobile Data)

. sum foreign

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
     foreign |         74    .2972973    .4601885          0          1
```


```stata
sysuse auto
tab foreign
```

```


. sysuse a(1978 Automobile Data)

. tab foreign

   Car type |      Freq.     Percent        Cum.
------------+-----------------------------------
   Domestic |         52       70.27       70.27
    Foreign |         22       29.73      100.00
------------+-----------------------------------
      Total |         74      100.00
```

# allcode


```r
sysuse auto
sum foreign
sysuse auto
tab foreign
```

# dd 
```stata  
sysuse auto
sum foreign
sysuse auto
tab foreign

``` 

