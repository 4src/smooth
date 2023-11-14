local ABCD={}
function ABCD:new(klass, b4)
    return {klass=klass, a=b4 or 0, b=0, c=0, d=0} end
  
  function ABCD:add(want,got)
    if   want == self.klass
    then if want==got       then self.d=self.d+1 else self.b=self.b+1 end
    else if got==self.klass then self.c=self.c+1 else self.a=self.a+1 end end end
  
  function ABCD:f(    p,r)  p,r=self:precision(),self:recall(); return (2*p*r)/(p+r) end
  function ABCD:g(    nf,r) nf,r=1-self:pf(),self:recall(); return (2*nf*r)/(nf+r) end
  function ABCD:pf()        return self.c/(self.a+self.c+1E-30) end
  function ABCD:recall()    return self.d/(self.b+self.d+1E-30) end
  function ABCD:accuracy()  return (self.a+self.d)/(self.a+self.b+self.c+self.d+1E-30) end
  function ABCD:precision() return self.d/(self.c+self.d+1E-30) end
  
  function ABCD:stats()
    return { _n=self.a+self.b+self.c+self.d,
             _a=self.a, _b=self.b, _c=self.c,  _d=self.d,
             acc=self:accuracy(), prec=self:precision(), pd=self:recall(), pf=self:pf(),
             f=self:f(),
             g=self:g()} end
  
  function ABCD.adds(t,want,got)
    t = t or {all={},n=0}
    t.all[want] = t.all[want] or ABCD(want, t.n)
    t.n = t.n + 1
    for _,abcd in pairs(t.all) do abcd:add(want,got) end
    return t end
  
  function ABCD.report(t,     u)
    u={}; for k,abcd in pairs(t.all) do u[k] = abcd:stats() end; return u end