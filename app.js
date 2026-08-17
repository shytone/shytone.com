(function(){
  var KEY="blog-theme";
  function apply(t){document.documentElement.setAttribute("data-theme",t);}
  function current(){
    try{return localStorage.getItem(KEY)||(window.matchMedia&&matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light");}
    catch(e){return "light";}
  }
  apply(current());
  var btn=document.getElementById("theme-toggle");
  if(btn){btn.addEventListener("click",function(){
    var t=current()==="dark"?"light":"dark";
    try{localStorage.setItem(KEY,t);}catch(e){}
    apply(t);
  });}
})();
