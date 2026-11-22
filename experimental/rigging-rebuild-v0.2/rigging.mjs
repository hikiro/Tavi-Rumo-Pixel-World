/* Portalbound V0.2 — procedural recovery rig, NOT original DINO Engine V5.
   Historic source-relative Rumo pivots retained as metadata, not world coordinates. */
export const spec={
 Tavi:{parts:['hair-back','rear-arm-upper','rear-arm-lower','rear-hand','rear-thigh','rear-shin','rear-foot','backpack','torso','scarf','neck','head','hair-front','front-thigh','front-shin','front-foot','front-arm-upper','front-arm-lower','front-hand'],hip:{x:0,y:-29},shoulder:{x:0,y:-44},neck:{x:0,y:-53},head:{x:0,y:-64},leg:[16,17],arm:[12,10]},
 Rumo:{layers:['tail','rear-leg','front-leg','neck','torso','spikes','head','jaw','forearm'],pivotSource:{headJaw:{x:20,y:21},tail:{x:43,y:29}},leg:[16,16],arm:[10,9]}
};
const P=(x,y)=>({x,y}),clamp=(a,b,c)=>Math.max(b,Math.min(c,a)),len=p=>Math.hypot(p.x,p.y);
export function ik(a,t,L1,L2,side=1){
 const dv=P(t.x-a.x,t.y-a.y),raw=len(dv),d0=Math.max(raw,1e-8);
 const d=clamp(d0,Math.abs(L1-L2)+.00001,L1+L2-.00001);
 const u=raw<1e-8?P(1,0):P(dv.x/d0,dv.y/d0);
 const proj=(L1*L1-L2*L2+d*d)/(2*d),height=Math.sqrt(Math.max(0,L1*L1-proj*proj));
 const j=P(a.x+u.x*proj-u.y*height*side,a.y+u.y*proj+u.x*height*side);
 return {start:{...a},joint:j,end:P(a.x+u.x*d,a.y+u.y*d),clamped:Math.abs(raw-d)>.0001};
}
const walk=(time,speed,stride,lift,sep)=>[-1,1].map((s,i)=>{
 const phase=2*Math.PI*time*speed+i*Math.PI;return P(s*sep+stride*Math.sin(phase),-lift*Math.max(0,Math.cos(phase)));
});
export function tavi(action='walk',time=0,progress=time%1){
 const s=spec.Tavi,moving=['walk','run'].includes(action),speed=action==='run'?2.2:1.1;
 let rootY=0,feet=moving?walk(time,speed,action==='run'?11:6,action==='run'?8:5,6):[P(-6,0),P(6,0)];
 if(action==='jump'){rootY=-26*Math.sin(Math.PI*clamp(progress,0,1));feet=[P(-5,rootY+5),P(7,rootY+8)]}
 if(action==='fall'){rootY=-30*(1-clamp(progress,0,1));feet=[P(-11,rootY+3),P(13,rootY+7)]}
 const hip=P(0,rootY+s.hip.y),sh=P(0,rootY+s.shoulder.y);
 const legs=feet.map((f,i)=>({...ik(P(i?-0+6:-6,hip.y),f,...s.leg,i?-1:1),contact:Math.abs(f.y)<.001}));
 const arms=[-1,1].map((side,i)=>{
  let hand=P(side*10+(moving?6*Math.sin(2*Math.PI*time*speed+i*Math.PI):0),sh.y+17);
  if(action==='block')hand=P(side*13,sh.y-11);
  if(action==='punch'&&i)hand=P(28,sh.y+4);
  if(action==='fireball'&&i)hand=P(25,sh.y-7);
  return ik(P(side*7,sh.y+2),hand,...s.arm,i?1:-1);
 });
 return {kind:'Tavi',action,root:P(0,rootY),legs,arms,hip,shoulder:sh,head:P(0,rootY-64),neck:P(0,rootY-53)};
}
export function rumo(action='walk',time=0,progress=time%1){
 const s=spec.Rumo,moving=['walk','chase'].includes(action),speed=action==='chase'?2.15:.92;
 let rootY=0;if(action==='jump')rootY=-25*Math.sin(Math.PI*clamp(progress,0,1));
 if(action==='lunge')rootY=-12*Math.sin(Math.PI*clamp(progress,0,1));
 const hips=[P(-19,rootY-22),P(16,rootY-22)];
 const feet=moving?walk(time,speed,action==='chase'?9:6,action==='chase'?6:4,0):[P(0,0),P(0,0)];
 const legs=hips.map((h,i)=>({...ik(h,P(h.x+feet[i].x,rootY?rootY+4:feet[i].y),...s.leg,i?-1:1),contact:!rootY&&Math.abs(feet[i].y)<.001}));
 const shoulder=P(19,rootY-39);
 return {kind:'Rumo',action,root:P(0,rootY),legs,shoulder,head:P(28,rootY-55),jaw:P(28,rootY-47),tail:P(-27,rootY-35),
 torso:P(0,rootY-36),jawOpen:action==='roar'?.9*Math.sin(Math.PI*clamp(progress,0,1)):.12,tailAngle:.16*Math.sin(time*speed*3.9),
 forearm:ik(shoulder,P(shoulder.x+12,shoulder.y+12),...s.arm,-1),sourcePivots:s.pivotSource};
}
const path=(c,ps,col,w)=>{c.strokeStyle=col;c.lineWidth=w;c.lineJoin='round';c.lineCap='round';c.beginPath();ps.forEach((p,i)=>i?c.lineTo(p.x,p.y):c.moveTo(p.x,p.y));c.stroke()};
const bone=(c,v,col,w)=>{path(c,[v.start,v.joint,v.end],'#142739',w+3);path(c,[v.start,v.joint,v.end],col,w)};
const ellipse=(c,x,y,rx,ry,color)=>{c.fillStyle=color;c.beginPath();c.ellipse(x,y,rx,ry,0,0,Math.PI*2);c.fill()};
export function drawTavi(c,p,x,y,scale=3){
 c.save();c.translate(x,y);c.scale(scale,scale);
 bone(c,p.legs[0],'#416984',7);bone(c,p.arms[0],'#d4a881',5);
 c.fillStyle='#4d5365';c.fillRect(4,p.shoulder.y-3,13,27);
 c.fillStyle='#6c9275';c.fillRect(-10,p.shoulder.y-2,21,25);
 c.fillStyle='#d97167';c.fillRect(-10,p.shoulder.y+1,21,4);
 c.fillStyle='#edc498';c.fillRect(-4,p.neck.y,8,10);
 c.fillStyle='#f1cda0';c.fillRect(-13,p.head.y-14,27,23);
 c.fillStyle='#513845';c.fillRect(-15,p.head.y-18,30,8);c.fillRect(-15,p.head.y-10,5,9);
 c.fillStyle='#1e2d3c';c.fillRect(7,p.head.y-3,3,3);
 bone(c,p.legs[1],'#527e95',7);bone(c,p.arms[1],'#e8c198',5);
 for(const v of p.legs){c.fillStyle='#1e364e';c.fillRect(v.end.x-6,v.end.y-3,12,4)}
 if(p.action==='block'){c.fillStyle='#6ec5bb';c.fillRect(p.arms[1].end.x-4,p.arms[1].end.y-12,8,24)}
 if(p.action==='fireball')ellipse(c,p.arms[1].end.x+11,p.arms[1].end.y,7,7,'#ffa846');
 c.restore();
}
export function drawRumo(c,p,x,y,scale=3){
 c.save();c.translate(x,y);c.scale(scale,scale);
 const t=p.tail,a=p.tailAngle;
 path(c,[P(t.x-40,t.y+13+a*45),P(t.x-16,t.y+12+a*20),t],'#193b45',19);
 path(c,[P(t.x-40,t.y+13+a*45),P(t.x-16,t.y+12+a*20),t],'#45987b',14);
 bone(c,p.legs[0],'#3c906e',11);
 ellipse(c,p.torso.x,p.torso.y,37,19,'#409575');ellipse(c,p.torso.x+7,p.torso.y+10,21,7,'#a2c58e');
 path(c,[P(p.shoulder.x-9,p.shoulder.y+6),p.head],'#4d9d7a',14);
 for(let i=-2;i<3;i++){const xx=p.torso.x+i*12,yy=p.torso.y-12+Math.abs(i)*4;
 c.fillStyle='#dfcc8c';c.beginPath();c.moveTo(xx-5,yy+4);c.lineTo(xx,yy-12);c.lineTo(xx+5,yy+4);c.fill()}
 bone(c,p.legs[1],'#55ae83',10);
 ellipse(c,p.head.x+8,p.head.y,20,12,'#4aa582');ellipse(c,p.head.x+23,p.head.y+5,13,7,'#72b98d');
 c.fillStyle='#142936';c.fillRect(p.head.x+12,p.head.y-5,4,4);
 c.save();c.translate(p.jaw.x+4,p.jaw.y);c.rotate(p.jawOpen*.58);path(c,[P(0,0),P(25,3)],'#203e48',8);path(c,[P(0,-1),P(25,2)],'#73ba91',5);c.restore();
 bone(c,p.forearm,'#4e9e7c',6);
 for(const v of p.legs){c.fillStyle='#204848';c.fillRect(v.end.x-6,v.end.y-3,12,4)}
 c.restore();
}
export function validate(p){const issues=[];for(const ch of [...p.legs,...(p.arms||[]),...(p.forearm?[p.forearm]:[])])for(const q of [ch.start,ch.joint,ch.end])if(!Number.isFinite(q.x)||!Number.isFinite(q.y))issues.push('nonfinite');return issues}
