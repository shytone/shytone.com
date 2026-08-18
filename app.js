(function(){
  var KEY="blog-theme", GEO="blog-geo", SOLAR="blog-solar";
  var ZEN=90.833, HOUR=3600e3;

  function apply(t){document.documentElement.setAttribute("data-theme",t);}
  function get(k){try{return localStorage.getItem(k);}catch(e){return null;}}
  function set(k,v){try{localStorage.setItem(k,v);}catch(e){}}
  function now(){return new Date();}

  function doy(d){return Math.floor((Date.UTC(d.getFullYear(),d.getMonth(),d.getDate())-Date.UTC(d.getFullYear(),0,0))/86400000);}
  function minOfDay(d){return d.getHours()*60+d.getMinutes()+d.getSeconds()/60;}

  // 标准太阳位置近似（NOAA 式），返回当地日出/日落分钟
  function solar(lat,lng,date){
    var d=doy(date), rad=Math.PI/180;
    var gamma=2*Math.PI/365*(d-1-lng/15/24);
    var eq=229.18*(0.000075+0.001868*Math.cos(gamma)-0.032077*Math.sin(gamma)-0.014615*Math.cos(2*gamma)-0.040849*Math.sin(2*gamma));
    var dec=0.006918-0.399912*Math.cos(gamma)+0.070257*Math.sin(gamma)-0.006758*Math.cos(2*gamma)+0.000907*Math.sin(2*gamma)-0.002697*Math.cos(3*gamma)+0.00148*Math.sin(3*gamma);
    var cost=Math.cos(ZEN*rad)/(Math.cos(lat*rad)*Math.cos(dec))-Math.tan(lat*rad)*Math.tan(dec);
    if(cost>1||cost<-1)return null;               // 极昼/极夜，无日出日落
    var ha=Math.acos(cost)/rad;
    var noon=720-4*lng-eq;
    var off=date.getTimezoneOffset();
    return {sr:noon-4*ha-off, ss:noon+4*ha-off};
  }

  function isDay(c){
    var s=solar(c.lat,c.lng,now());
    if(!s)return null;
    var cur=minOfDay(now());
    return s.sr<s.ss ? (cur>=s.sr&&cur<s.ss) : (cur>=s.sr||cur<s.ss);
  }

  function readMode(){
    var m=get(KEY);
    return (m==="light"||m==="dark")?m:"auto";
  }
  function fallbackTheme(){
    try{return window.matchMedia&&matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light";}
    catch(e){return "light";}
  }
  function cachedGeo(){
    try{var c=JSON.parse(get(GEO));if(c&&typeof c.lat==="number")return c;}catch(e){}
    return null;
  }

  var btn=document.getElementById("theme-toggle");
  var coords=null, timer=null;

  function schedule(min){
    if(timer)clearTimeout(timer);
    timer=setTimeout(tick,Math.max(60e3,min*60000+1000));
  }
  function tick(){
    if(readMode()!=="auto")return;
    coords=coords||cachedGeo();
    if(!coords){schedule(30);return;}
    var day=isDay(coords);
    if(day===null){schedule(30);return;}
    apply(day?"light":"dark");
    set(SOLAR,JSON.stringify({day:day?1:0,at:Date.now()}));
    var s=solar(coords.lat,coords.lng,now()), delta=1440;
    if(s){var cur=minOfDay(now()), nxt=day?s.ss:s.sr; delta=nxt-cur; if(delta<=0)delta+=1440;}
    schedule(delta);
  }
  function resolve(){
    if(readMode()!=="auto")return;
    coords=coords||cachedGeo();
    if(coords){tick();return;}
    if(!navigator.geolocation)return;
    navigator.geolocation.getCurrentPosition(function(p){
      coords={lat:p.coords.latitude,lng:p.coords.longitude};
      set(GEO,JSON.stringify(coords));
      tick();
    },function(){},{maximumAge:HOUR,timeout:15000});
  }
  function setIcon(){
    if(!btn)return;
    var m=readMode();
    btn.textContent=m==="light"?"🌞":(m==="dark"?"🌙":"🌗");
    btn.title=m==="auto"?"主题：自动（随日出日落）":(m==="light"?"主题：浅色（点击切换）":"主题：深色（点击切换）");
  }

  if(btn){
    btn.addEventListener("click",function(){
      var m=readMode();
      var next=m==="dark"?"light":(m==="light"?"auto":"dark");
      set(KEY,next);
      if(next==="auto"){
        coords=coords||cachedGeo();
        var d=coords?isDay(coords):null;
        apply(d===null?fallbackTheme():d?"light":"dark");
        resolve();
      }else{apply(next);}
      setIcon();
    });
  }
  setIcon();
  resolve();
  document.addEventListener("visibilitychange",function(){if(!document.hidden)resolve();});
  window.addEventListener("pageshow",resolve);
})();
