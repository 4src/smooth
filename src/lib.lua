local l={}
--- lint ------------------------------------------------------
local b4={}; for k,v in pairs(_ENV) do b4[k]=k end

function l.rogues()
  for k,v in pairs(_ENV) do 
    if not b4[k] then print("#W ?",k,type(v)) end end end

--- objects -----------------------------------------------------
l.isa = getmetatable

local id=0
function l.obj(s,    t)
  t = {}
  return setmetatable(t, { __call=function(klass,...)
    klass.__index    = klass
    klass.__tostring = l.o
    id = id + 1
    local i = setmetatable({ako=s,id=id},t)
    return setmetatable(t.new(i,...) or i,t) end}) end

-- lists -------------------------------------------------------
function l.push(t,x) t[1+#t]=x ; return x end

--- fisheryates
function l.shuffle(t,   j)
  for i=#t,2,-1 do j=math.random(i); t[i],t[j]=t[j],t[i] end; return t end

--- sortedItems
function l.order(t,    n,i,u)
  u={}; for k,_ in pairs(t) do u[1+#u] = k; end
  table.sort(u)
  i=0
  return function()
    if i < #u then i=i+1; return u[i], t[u[i]] end end end 

--- sortonkeys
function l.lt(x) return function(a,b) return a[x] < b[x] end end
function l.gt(x) return function(a,b) return a[x] > b[x] end end

--- schwartzianTransform
function l.keysort(t,fun)
  local decorated, undecorated = {},{}
  for _,v in pairs(t) do l.push(decorated, {x=v, y=fun(v)}) end
  table.sort(decorated, function(a,b) return a.y < b.y end) 
  for _,v in pairs(decorated) do l.push(undecorated, v.x) end
  return undecorated end

function l.slice(t, nGo, nStop, nInc,       u)
  if nGo   and nGo   < 0 then nGo  = #t + nGo +1 end
  if nStop and nStop < 0 then nStop= #t + nStop  end
  u={}
  for i=(nGo or 1)//1,(nStop or #t)//1,(nInc or 1)//1 do 
    u[1+#u]=t[i] end
  return u end

function l.report(t, n,      f,u,s)
  n = n or 10 
  f = function(x) return l.fmt("%-"..n.."s",l.rnd(x,2)) end
  for what,cells in l.order(t) do
    if not u then
      u={f("")}; for k,v in l.order(cells) do u[1+#u]=f(k) end
      print(l.o(table.concat(u))) end
    u = {f(what)}; for _,v in l.order(cells) do u[1+#u] = f(v)  end
    print(table.concat(u)) end end

-- maths -------------------------------------------------------
function l.rnd(x,  d)
  if type(x) ~= "number" then return x end
  if math.floor(x) == x then return x
  else local mult = 10^(d  or 2)
       return math.floor(x*mult+0.5)/mult end end

function l.ent(t,     e,N)
  e,N = 0,0
  for _,n in pairs(t) do N = N + n end
  for _,n in pairs(t) do e = e - n/N*math.log(n/N,2) end
  return e end

-- strings -----------------------------------------------------
l.fmt=string.format

function l.o(it,d,          u,fun)
  function fun(k,x) return #it==0 and l.fmt(":%s %s",k,x) or x end
  if type(it) == "number" then return tostring(l.rnd(it,d)) end
  if type(it) ~= "table"  then return tostring(it) end
  u={}; for k,v in l.order(it) do u[1+#u] = tostring(fun(k, l.o(v,d))) end
  return "{"..table.concat(u," ").."}" end

function l.make(s,    fun)
  function fun(s) return s=="true" or (s~="false" and s) end
  return math.tointeger(s) or tonumber(s) or fun(s:match'^%s*(.*%S)') end

function l.csv(sFilename,   filter, src,i)
  src = io.input(sFilename)
  filter = filter or function(x) return x end
  i=0
  return function(    s,t)
    s = io.read()
    if   s 
    then i=i+1; t={}
         for s1 in s:gmatch("([^,]+)") do l.push(t,l.make(s1)) end; 
         return i,filter(t)
    else io.close(src) end end end

function l.items(t,     i)
  i=0; return function() if i < #t then i=i+1; return i,t[i] end end end

-- settings ----------------------------------------------------
function l.settings(s,    t,pat)
  t={}
  pat = "\n[%s]+[-][%S][%s]+[-][-]([%S]+)[^\n]+= ([%S]+)"
  for k,s1 in s:gmatch(pat) do t[k]= l.make(s1) end
  return t,s end

function l.cli(t)
  for k,v in pairs(t) do
    v = tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(k:sub(1,1)) or x=="--"..k then
        v= ((v=="false" and "true") or (v=="true" and "false") or arg[n+1])
        t[k] = l.make(v) end end end
  return t end

----------------------------------------------------------------
return l
