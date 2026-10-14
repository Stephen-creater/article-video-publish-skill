// 从 Gemini 对话里抓最新一张图的「完整尺寸」原图（Gemini 的下载按钮在自动化里不触发浏览器下载，改为截网络请求再 fetch）。
// 用法：先把配置写到 ~/.cache/gemini_grab.json：{"space": TaskSpace编号, "out": "保存路径（不带扩展名）"}，然后：
//   ego-browser nodejs < gemini_grab.mjs
// （ego-browser 的脚本进程收不到 shell 环境变量，所以配置路径写死）
const fs=await import("node:fs/promises");
const os=await import("node:os");
const cfg=JSON.parse(await fs.readFile(os.homedir()+"/.cache/gemini_grab.json","utf8"));
const t=await taskSpace(cfg.space); const p=t.page("p1");
await p.waitForFunction(()=>[...document.querySelectorAll('model-response img')].some(i=>i.naturalWidth>400), undefined, {timeout:240000});
await p.cdp("Network.enable",{maxResourceBufferSize:50000000,maxTotalBufferSize:200000000}); await p.events();
await p.evaluate(()=>{const a=[...document.querySelectorAll('model-response img')].filter(i=>i.naturalWidth>400); a[a.length-1].scrollIntoView({block:"center"});});
await p.waitForTimeout(500);
const box=await p.evaluate(()=>{const a=[...document.querySelectorAll('model-response img')].filter(i=>i.naturalWidth>400); const r=a[a.length-1].getBoundingClientRect(); return {x:r.x+r.width/2,y:r.y+r.height/2};});
await p.mouse.move(box.x,box.y); await p.waitForTimeout(700);
await p.evaluate(()=>{const b=[...document.querySelectorAll('button[aria-label="下载完整尺寸的图片"]')]; b[b.length-1].click();});
let rid=null,mime="",url="",done=new Set();
for(let k=0;k<60&&!(rid&&done.has(rid));k++){
  await p.waitForTimeout(1000);
  for(const e of await p.events()){const pr=e.params||{}; const m=e.method||e.name;
    if(m==="Network.responseReceived"&&/rd-gg/.test(pr.response?.url||"")&&/^image\//.test(pr.response?.mimeType||"")){rid=pr.requestId;mime=pr.response.mimeType;url=pr.response.url;}
    if(m==="Network.loadingFinished") done.add(pr.requestId);}
}
if(!rid){console.log("没截到原图");}else{const f=cfg.out+(mime.includes("png")?".png":".jpg"); const r=await p.fetch(url,{saveAs:f,timeout:60000}); console.log("已保存",f,r.status,(await fs.stat(f)).size);}
