
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
