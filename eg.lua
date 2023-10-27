local s=require"smooth"
local l=require"lib"
local the=s.the

local eg={}

local function try(s, fun)
  math.randomseed(the.seed)
  print("==> ".. s)
  if fun()==false then 
    print("❌ FAIL : ".. s); return true end end

local function run()
  l.cli(the)
  if the.help then print("hello") else
    for _,com in pairs(arg) do
      if eg[com] then try(com, eg[com]) end end end
  l.rogues() end

-- eg ----------------------------------------------------------
