local smo = require"smooth"
local l   = require"lib"
local the, help = smo.the, smo.help

local eg = {}
local _print = print
print = function(...) if not the.quiet then _print(...) end end

local function try(s, fun)
  math.randomseed(the.seed)
  io.write("⭐️ ".. s.." ")
  if fun()==false then
    io.write("❌ FAIL\n"); return true
  else io.write("✅ \n") end end

local function run()
  l.cli(the)
  if the.help then print("hello") else
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
----------------------------------------------------------------
run()