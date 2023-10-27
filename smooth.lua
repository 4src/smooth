-- vim: set et sts=2 sw=2 ts=2 :  
local l = require"lib"
local the,help = l.settings[[
SMOTH : sequential model optimization
(c)2023, Tim Menzies <timm@ieee.org>, BSD-2

OPTIONS:
  -b --bins    number of bins                  = 6
  -f --file    file name                       = ../data/auto93.csv
  -k --k       low frequency hack for classes  = 1 
  -m --m       low frequency hack for E        = 2
  -s --seed    random seed                     = 1234567891
  -q --quiet   hide print output               = false]]

local SYM,NUM,COLS = l.obj"SYM", l.obj"NUM", l.obj"COLS"
local ROW, DATA    = l.obj"ROW", l.obj"DATA"

-- SYM, NUM ----------------------------------------------------
function SYM:new(at,s) 
    return {symp=true, at=at,s=s,has={},mode=nil,most=0} end

function NUM:new(at,s) 
  return {at=at,s=s,n=0, mu=0, m2=0, sd=0, lo=math.huge, hi= -math.huge,
          heaven = (s or ""):find"-$" and 0 or 1} end

function NUM:add(x,     d)
  if x~="?" then
    self.n = self.n + 1
    d       = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = nil
    if x > self.hi then self.hi = x end
    if x < self.lo then self.lo = x end end end

function SYM:add(x,     tmp)
  if x~="?" then
    self.n = self.n + 1
    tmp = 1 + (self.has[x] or 0)
    self.has[x] = tmp
    if tmp > self.most then self.most,self.mode = tmp,x end end end

function NUM:mid() return self.mu end
function NUM:div() 
  self.sd = self.sd or (self.m2/(self.n - 1))^.5; return self.sd end

function SYM:mid() return self.mode end
function SYM:div() return l.ent(self.has) end 

function NUM:bin(x) return (x-self.mu)/self:sd()/(6/the.bins)// 1 end
function SYM:bin(x) return x end

function NUM:norm(x) 
  return x=="?" and x or (x - self.lo)/ (self.hi - self.lo + 1e-30) end

-- COLS ---------------------------------------------------------
function COLS:new(t,       what,where)
  self.all, self.x, self.y,_ = {},{},{},{}
  for at,s in pairs(t) do
    what  = s:find"^[A-Z]" and NUM or SYM
    where = s:find"X$" and _ or (s:find"^[+-!]$" and self.x or self.y)
    l.push(where, l.push(self.all, what(at,s)))end end

function COLS:xs(t) self:adds(self.x, t) end
function COLS:ys(t) self:adds(self.y, t) end

function COLS:adds(xycols, t)
  for _,col in pairs(xycols) do col:add(t.cells[col.at]) end end

--- ROW --------------------------------------------------------
function ROW:new(t) return {cells=t} end

function ROW:classify(datas,    n,h,most,tmp,out)
  n,h = 0,0
  most = -math.huge
  for _,data in pairs(datas) do h=h+1; n=n+#data.rows end
  for k,data in pairs(datas) do
    tmp = data:like(self,n,h)
    if tmp > most then out,most = k,tmp end end
  return out,most end

-- DATA --------------------------------------------------------
function DATA:new(src)
  self.rows, self.cols = {}, nil
  if type(src)=="string" 
  then for  t in l.csv(the.file)   do self:add(ROW(t)) end
  else for _,t in pairs(src or {}) do self:add(t) end end end

function DATA:add(row)
  if   self.cols
  then self.cols:xs(row); self.cols:ys(row)
  else self.cols = COLS(row.cells) end end

function DATA:like(row,  n,h)
  local prior,out,col,b,inc
  prior = (#self.rows + the.k) / (n + the.k * h)
  out   = math.log(prior)
  for at,v in pairs(row) do
    if v ~= "?" then
      col = self.cols.all[at]
      b   = col:bin(v)
      inc = ((col.has[b] or 0) + the.m*prior)/(col.n+the.m)
      out = out + math.log(inc) end end
  return out end

function DATA:d2h(t,    n,d)
  for _,col in pairs(self.cols.y) do
    n = n + 0
    d = d + (col.heaven - col:norm(t.cells[col.at]))^2 end
  return (d/n)^.5 end

-------------------------------------------------
-- function main()
--   cols = nil
--   ds = NUM()
--   rows, seen = {},{}
--   for t in csv(file) do  l.push(rows,t) end
--   for n,t in pairs(l.shuffle(rows)) do
--     if n==1 then cols=COLS(t) else l.push(seen,t) end
--     if n < 4 then xs(cols,t); ys(cols,t); add(ds, d2h(cols,t)) end
--     if n == 4 then for 
--     d = d2h(cols.t)
--     if d > mid(ds) 
--     add(ds,d)

--       adds(cols,"x",t)

return {the=the, help=help, SYM=SYM, NUM=NUM,
        COLS=COLS, ROW=ROW, DATA=DATA}