local smo = require"smooth"
local l   = require"lib" 

local o,push        = l.o, l.push
local the           = smo.the
local SYM,NUM,COLS  = smo.SYM,  smo.NUM, smo.COLS
local COLS,ROW,DATA = smo.COLS, smo.ROW, smo.DATA

local eg = {}
local _print = print
print = function(...) if not the.quiet then _print(...) end end

-- start-up code -----------------------------------------------
local function try(s, fun)
  math.randomseed(the.seed)
  io.write("▶️ ".. s)
  if fun()==false 
  then print(" ❌ FAIL"); return true
  else print(" ✅ PASS"); return false end  end

local function run()
  l.cli(the)
  if the.help then print(smo.help) else
    for _,com in pairs(arg) do 
      if eg[com] then try(com, eg[com]) end end end
  l.rogues() end

-- eg ----------------------------------------------------------
function eg.all(     oops)
  oops = -1 -- we have one test that deliberately fails
  for k,fun in l.items(eg) do
    if k~="all" then 
      if try(k,fun) then oops = oops + 1 end end end
  l.rogues()
  os.exit(oops) end

function eg.fails() return false end
function eg.the()   print(l.o(the)) end

function eg.csv(      n)
  n=0; for t in l.csv(the.file) do n = n + #t end 
  return n ==399*8 end  

function eg.cols(     c)
  c=COLS{"Name","Age","employed","Happy+"}
  for _,col in pairs(c.all) do print(col:div(), col) end end

function eg.data(     d)
  d = DATA(the.file)
  for _,col in pairs(d.cols.all) do print(o{col:mid(),col:div(), col}) end end
  --print(o(d.cols.x)) end
--  print(o(d:stats())) end

function eg.sym(s)
  s = SYM()
  for _,x in pairs{1,1,1,1,2,2,3} do s:add(x) end
  print(s:mid(), s:div())
  return 1.37< s:div() and s:div()< 1.38 end

function eg.num(     n,md,sd)
  n = NUM() 
  for i=1,100 do n:add( i) end
  md,sd = n:mid(), n:div()
  print(md,sd)
  return 50 < md and md < 51 and 29 < sd and sd < 30 end

function eg.stats(     d)
  d = DATA(the.file)
  print("mid",o(d:stats())) 
  print("div",o(d:stats(d,"div",d.cols.y))) end

function eg.clone(      d1,d2,s1,s2,good)
  d1  = DATA(the.file)
  d2  = d1.clone(d1.rows)
  s1  = d1:stats()
  s2  = d2:stats()
  good= true
  for k,v in pairs(s1) do good = good and v == s2[k] end 
  print("original", o(s1))
  print("cloned  ", o(s2)) 
  return good end

function eg.dist(     t,r1,r2,d)
  t,d = {}, DATA(the.file); 
  for i=1,20 do 
    r1,r2 = l.any(d.rows),  l.any(d.rows) 
    push(t, o(d:dist(r1, r2),2)) end 
  print(o(l.sort(t),2)) end

function eg.heaven(     t,r1,r2,d)
  t, d = {}, DATA(the.file); 
  for i=1,20 do 
    r1  = l.any(d.rows)
    push(t, d:d2h(r1)) end
  print(o(t,2)) end

function eg.heavens(     t,d,n)
  t, d = {}, DATA(the.file)
  n = (#d.rows) ^.5  
  t = l.keysort(d.rows, function(row1,x) return d:d2h(row1) end) 
  print("best", o(d:clone(l.slice(t,1,n)):stats()))
  print("worst", o(d:clone(l.slice(t,-n)):stats())) end
----------------------------------------------------------------
run()