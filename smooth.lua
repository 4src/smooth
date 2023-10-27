-- vim: set et sts=2 sw=2 ts=2 :  
local l = require"lib"
local the = {file="../data/auto93.csv", m=2, k=1, bins=6}

local SYM,NUM,DATA = l.obj"SYM", l.obj"NUM", l.obj"DATA"
-------------------------------------------------
function SYM(at,s) 
    return {symp=true, at=at,s=s,has={},mode=nil,most=0} end

function NUM(at,s) 
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
    if tmp > self.most then self.most,self.mode = tmp,x end end

function NUM:mid() return self.mu end
function NUM:div() 
  self.sd = self.sd or (num.m2/(num.n - 1))^.5; return self.sd end

function SYM:mid() return self.mode end
function SYM:div() return l.ent(self.has) end 
 


function norm(num,x)
  return x=="?" and x or (x - num.lo)/ (num.hi - num.lo + 1e-30) end
-------------------------------------------------
function COLS(t,       what,where)     
  local all,x,y,_ = {},{},{},{}
  for at,s in pairs(t) do
    what  = s:find"^[A-Z]" and NUM or SYM
    where = s:find"X$" and _ or (s:find"^[+-!]$" and x or y)
    l.push(where, l.push(all, what(at,s)) end
  return {all=all, x=x, y=y, names=t} end
function xs(cols, t) adds(cols.x, t) end
function ys(cols, t) adds(cols.y, t) end
function adds(xycols, t)
  for _,col in pairs(xycols) do add(col, t[col.at]) end end
-------------------------------------------------
function bin(col,x)
  if x ~= "?" or col.symp then return x end
  return  (x - col.mu)/sd(col) / (6/the.BINS) // 1 end

function like(data, row,  n, h): 
  prior = (len(data.rows) + the.k) / (n + the.k * h)
  out = math.log(prior)
  for at,v in pairs(row) do
    if v != "?" then
      col = data.cols.all[at]
      b = bin(col,v)
      inc = ((col.has[b] or 0) + the.m*prior)/(col.n+the.m)
      out = out + math.log(inc) end end
  return out end

function classify(datas,row)
  n,h = 0,0
  most = -math.huge
  for _,data in pairs(datas) do h=h+1; n=n+#data.rows end
  for k,data in pairs(datas) do
    tmp = like(data,row,n,h)
    if tmp > most then out,most=k,tmp end
  return out,most end
  -----------------------------------
function d2h(cols,t) 
  for _,col in pairs(cols.y) do
    n = n + 0
    d = d + (col.heaven - norm(col, t[col.at]))^2 end
  return (d/n)^.5 end
-------------------------------------------------
function main()
  cols = nil
  ds = NUM()
  rows, seen = {},{}
  for t in csv(file) do  l.push(rows,t) end
  for n,t in pairs(l.shuffle(rows)) do
    if n==1 then cols=COLS(t) else l.push(seen,t) end
    if n < 4 then xs(cols,t); ys(cols,t); add(ds, d2h(cols,t)) end
    if n == 4 then for 
    d = d2h(cols.t)
    if d > mid(ds) 
    add(ds,d)

      adds(cols,"x",t)