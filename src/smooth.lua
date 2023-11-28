-- vim: set et sts=2 sw=2 ts=2 :  
local l = require"lib"
local the,help = l.settings[[

SMOOTH : sequential model optimization
(c)2023, Tim Menzies <timm@ieee.org>, BSD-2

USAGE: 
  lua eg.lua [OPTIONS] [ACTION]

  or:
  smo = require"smooth"
  -- then see the "eg" functions in eg.lua

OPTIONS:
  -b --bins    number of bins                    = 6
  -d --d       round nums to d decimal places    = 2
  -f --file    file name                         = ../data/auto93.csv
  -h --help    show help                         = false
  -k --k       low frequency hack for classes    = 1 
  -m --m       low frequency hack for E          = 2
  -s --seed    random seed                       = 1234567891
  -q --quiet   hide print output                 = false
  -w --wait    classfy after seeing 'wait' items = 3]]

local SYM,NUM,COLS = l.obj"SYM", l.obj"NUM", l.obj"COLS"
local ROW,DATA     = l.obj"ROW", l.obj"DATA"
local ABCD,NB      = l.obj"ABCD", l.obj"NB"

local o,push = l.o,l.push
-- SYM, NUM ----------------------------------------------------
--- colnew
function SYM:new(at,s) 
    return { at=at, txt=s, n=0,  use= not (s or ""):find"X$",
            has={}, mode=nil, most=0}  end

function NUM:new(at,s) 
  return { at=at, txt=s, n=0,  use= not (s or ""):find"X$",
           mu=0, m2=0, sd=0, lo=1E30, hi= -1E30,
           heaven = (s or ""):find"-$" and 0 or 1} end

--- coladd
function NUM:add(x,     d)
  if x~="?" then
    self.n = self.n + 1
    d       = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n > 1 and (self.m2/(self.n - 1))^.5 or 0
    if x > self.hi then self.hi = x end
    if x < self.lo then self.lo = x end end end

function SYM:add(x,     tmp)
  if x~="?" then
    self.n = self.n + 1
    tmp = 1 + (self.has[x] or 0)
    self.has[x] = tmp
    if tmp > self.most then self.most,self.mode = tmp,x end end end

     
--- colquery
function NUM:mid() return self.mu end
function SYM:mid() return self.mode end

function NUM:div() return self.sd end
function SYM:div() return l.ent(self.has) end

--- colchop
function NUM:norm(x) 
  return x=="?" and x or (x - self.lo)/ (self.hi - self.lo + 1e-30) end

function NUM:bin(x) return (.5+(x-self.mu)/self:div()/(6/the.bins))// 1 end
function SYM:bin(x) return x end

-- COLS ---------------------------------------------------------
--- colsmake
function COLS:new(t,       col)
  self.all, self.x, self.y = {},{},{}
  self.names, self.klass   = t, nil
  for at,s in pairs(t) do 
    col = l.push(self.all, (s:find"^[A-Z]" and NUM or SYM)(at,s))
    if col.use then
      (s:find"[!+-]$" and self.y or self.x)[at] = col
      if s:find"!$" then self.klass = col end end end end

--- colsadd
function COLS:xs(t) self:adds(self.x, t); return self end
function COLS:ys(t) self:adds(self.y, t); return self end

function COLS:adds(xycols, t)
  for _,col in pairs(xycols) do
    col:add(t.cells[col.at]) end end

--- ROW --------------------------------------------------------
function ROW:new(t) return {cells=t} end

function ROW:d2h(data,    n,d)
  n,d = 0,0
  for _,col in pairs(data.cols.y) do
    n = n + 1
    d = d + (col.heaven - col:norm(self.cells[col.at]))^2 end
  return (d/n)^.5 end

function ROW:klass(data)
  return self.cells[data.cols.klass.at] end

function ROW:classify(datas,     n,h,most,tmp,out)
  most,n,h = -1E30,0,0
  for _,data in pairs(datas) do h=h+1; n=n+#data.rows end
  for k,data in pairs(datas) do
    tmp = self:like(data,n,h)
    if tmp > most then out,most = k,tmp end end
  return out,most end

-- like ----------------------------------------------------------
function ROW:like(data,n,h,       prior,out,col,b,inc)
  prior = (#data.rows + the.k) / (n + the.k * h)
  out   = math.log(prior)
  for at,v in pairs(self.cells) do
    col = data.cols.x[at]
    if col and v ~= "?" then
      out = out + math.log(col:like(v,prior)) end end
  return out end

function SYM:like(v,prior)
   return ((self.has[v] or 0) + the.m*prior)/(self.n+the.m) end

function NUM:like(v,_,     nom,denom)
  if v > self.mu + 4*self.sd then return 0 end
  if v < self.mu - 4*self.sd then return 0 end
  nom   = math.exp(-.5*((v - self.mu)/self.sd)^2)
  denom = (self.sd*((2*math.pi)^0.5))
  return nom/denom end

-- NB ----------------------------------------------------------
local function _adds(self,src)
  if   type(src)=="string"
  then for t   in l.csv(src)       do self:add(ROW(t)) end
  else for row in pairs(src or {}) do self:add(row) end end
  return self end

function NB:new(src)
  self.datas, self.all, self.abcd = {}, nil,nil
  _adds(self,src)  end

function NB:add(row,n)
  if    n>1
  then  if n > the.wait then self:classify(row) end
        self:klass(row):add(row)
  else  self.all = DATA(l.items{row}) end end

function NB:classify(row,     got,want)
  got  = row:classify(self.datas)
  want = row:klass(self.all)
  self.abcd = ABCD.adds(self.abcd,want,got) end

function NB:klass(row,     k)
  k = row:klass(self.all)
  self.datas[k] = self.datas[k] or self.all:clone()
  return self.datas[k] end

-- DATA --------------------------------------------------------
function DATA:new(src)
  self.rows, self.cols = {}, nil 
  _adds(self,src)  end

function DATA:clone(src)
  return _adds(DATA({ROW(self.cols.names)}), src) end

function DATA:add(row)
  if   self.cols
  then self.cols:xs(row):ys(row)
       push(self.rows, row)
  else self.cols = COLS(row.cells) end end

function DATA:stats(  digits,fun,cols,     t,get)
  function get(col) return getmetatable(col)[fun or "mid"](col) end
  t = {N = #self.rows}
  for _,col in pairs(cols or self.cols.y) do t[col.txt] = l.o(get(col),digits) end
  return t end

function DATA:sorted()
  return l.keysort(self.rows, function(row) return row:d2h(self) end) end
-------------------------------------------------
function ABCD:new(klass, b4)
  return {klass=klass, a=b4 or 0, b=0, c=0, d=0} end

function ABCD:add(want,got)
  if   want == self.klass
  then if want==got       then self.d=self.d+1 else self.b=self.b+1 end
  else if got==self.klass then self.c=self.c+1 else self.a=self.a+1 end end end

function ABCD:f()         local p,r=self:precision(),self:recall(); return (2*p*r)/(p+r)   end
function ABCD:g()         local nf,r=1-self:pf(),    self:recall(); return (2*nf*r)/(nf+r) end
function ABCD:pf()        return self.c/(self.a+self.c+1E-30) end
function ABCD:recall()    return self.d/(self.b+self.d+1E-30) end
function ABCD:accuracy()  return (self.a+self.d)/(self.a+self.b+self.c+self.d+1E-30) end
function ABCD:precision() return self.d/(self.c+self.d+1E-30) end

function ABCD:stats()
  return {
    _n=self.a+self.b+self.c+self.d,
    _a=self.a, _b=self.b, _c=self.c,  _d=self.d,
    acc=self:accuracy(),  prec=self:precision(), 
    pd=self:recall(),     pf=self:pf(),
    f=self:f(),           g=self:g()} end

function ABCD.adds(t,want,got)
  t = t or {all={},n=0}
  t.all[want] = t.all[want] or ABCD(want, t.n)
  t.n = t.n + 1
  for _,abcd in pairs(t.all) do abcd:add(want,got) end
  return t end

function ABCD.report(t,     u)
  u={}; for k,abcd in pairs(t.all) do u[k] = abcd:stats() end; return u end

return {the=the, help=help, SYM=SYM, NUM=NUM,
        COLS=COLS, ROW=ROW, DATA=DATA, NB=NB, ABCD=ABCD}