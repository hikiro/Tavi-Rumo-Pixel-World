import assert from 'node:assert/strict';
import {spec,ik,tavi,rumo,validate} from './rigging.mjs';
const dist=(a,b)=>Math.hypot(a.x-b.x,a.y-b.y),near=(a,b)=>assert.ok(Math.abs(a-b)<.004,`${a} not near ${b}`);
let count=0,contacts=0;
for(const [character,actions,fn,length] of [
 ['Tavi',['idle','walk','run','jump','punch','block','fireball','fall'],tavi,spec.Tavi.leg],
 ['Rumo',['idle','walk','chase','jump','roar','lunge'],rumo,spec.Rumo.leg]
]){
 for(const action of actions)for(let f=0;f<120;f++){
  const p=fn(action,f/60,f/119);
  assert.deepEqual(validate(p),[]);
  for(const leg of p.legs){near(dist(leg.start,leg.joint),length[0]);near(dist(leg.joint,leg.end),length[1]);if(leg.contact&&!leg.clamped){near(leg.end.y,0);contacts++}}
  count++;
 }
}
assert.equal(spec.Tavi.parts.length,19);
assert.equal(spec.Rumo.layers.length,9);
assert.deepEqual(spec.Rumo.pivotSource.headJaw,{x:20,y:21});
assert.deepEqual(spec.Rumo.pivotSource.tail,{x:43,y:29});
for(const p of [{x:0,y:0},{x:9999,y:1},{x:0,y:9999}]){const v=ik({x:0,y:0},p,16,17);assert.ok(Number.isFinite(v.joint.x+v.joint.y))}
console.log('PASS',JSON.stringify({poseFrames:count,contactSamples:contacts,originalSourceFidelity:'not established'}));