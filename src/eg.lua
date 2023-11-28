local smo = require"smooth"
local l   = require"lib"

local o,csv,push        = l.o, l.csv, l.push
local the           = smo.the
local SYM,NUM,COLS  = smo.SYM,  smo.NUM, smo.COLS
local COLS,ROW,DATA = smo.COLS, smo.ROW, smo.DATA
local ABCD,NB       = smo.ABCD, smo.NB

local eg = {}
local _print = print
print = function(...) if not the.quiet then _print(...) end end

-- start-up code -----------------------------------------------
local function try(s, fun)
  math.randomseed(the.seed)
  io.write("🔷 ".. s.." ")
  if fun()==false 
  then print(" ❌ FAIL"); return true
  else print("✅ PASS"); return false end  end

local function run()
  l.cli(the)
  if the.help then print(smo.help) else
    for _,com in pairs(arg) do
      if eg[com] then try(com, eg[com]) end end end
  l.rogues() end

-- eg ----------------------------------------------------------
function eg.all(     oops)
  oops = -1 -- we have one test that deliberately fails
  for k,fun in l.order(eg) do
    if k~="all" then 
      if try(k,fun) then oops = oops + 1 end end end
  l.rogues()
  os.exit(oops) end

function eg.fails() return false end
function eg.the()   print(l.o(the)) end

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

function eg.csv(      n)
  n=0; for _,t in l.csv(the.file) do
    if n>0 then assert(type(t[1])=="number") end
    n = n + #t end
  return n ==399*8 end

function eg.cols(     c)
  print""
  c=COLS{"Name","Age","employed","Happy+"}
  for _,col in pairs(c.all) do print(col:div(), col) end end

function eg.data(     d)
  print(the.file)
  d = DATA(the.file)
  for n,col in pairs(d.cols.all) 
     do print(n,l.o{txt=col.txt,mid=col:mid(), div=col:div()}) end
  print(o(d:stats(3))) end

function eg.clone(     d)
  d = DATA(the.file)
  print("\n"..o(d:stats()))
  print(o(d:clone(d.rows):stats())) end

function eg.heaven(     d)
  d = DATA(the.file)
  print""
  for n,row in pairs(d.rows) do
    if (n % 30) == 0 then
     print(l.rnd(row:d2h(d)), o(row.cells)) end end end

function eg.heavens(      d,rows)
  d = DATA(the.file)
  rows = d:sorted()
  print""
  l.report{base  = d:stats(),
           first = d:clone( l.slice(rows,1,20) ):stats(),
           last  = d:clone( l.slice(rows,-20)  ):stats()} end

function eg.abcd(     x)
  print""
  for _ = 1,6 do x= ABCD.adds(x,"yes",   "yes") end
  for _ = 1,2 do x= ABCD.adds(x,"no",    "no") end
  for _ = 1,5 do x= ABCD.adds(x,"maybe", "maybe") end
  x= ABCD.adds(x,"maybe","no")
  l.report(ABCD.report(x),6) end

function eg.nb(     nb)
  print"" 
  nb = NB("../data/diabetes.csv")
  l.report(ABCD.report(nb.abcd),6) end
----------------------------------------------------------
run()