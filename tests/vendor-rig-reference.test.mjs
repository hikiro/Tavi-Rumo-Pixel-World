import assert from 'node:assert/strict';
import {readFileSync,existsSync} from 'node:fs';
import {createHash} from 'node:crypto';
const read=p=>readFileSync(new URL('../'+p,import.meta.url));
const sha=p=>{const b=read(p);return createHash('sha1').update('blob '+b.length+String.fromCharCode(0)).update(b).digest('hex')};
const root='third_party/';
const official={
'gbot-skeleton-reference/player/gBot.png':'183c8985ab4ccfd0d9877e41b34a8c7cf3c66f6a',
'gbot-skeleton-reference/player/player.tscn':'6eba07a1bafc0b3c73bf335f637231070fddcc99',
'gbot-skeleton-reference/player/player.gd':'736aec80d43f189c155cafc5acac20a4560b68df',
'godot-pixel-cutout-rig/cutout_rig/cutout_rig.gd':'a159ae08bbb018139b4083818eaffbb4c4c1efc3',
'godot-pixel-cutout-rig/cutout_rig/parts/head.png':'38a8def3043549d184029cad2c3b87dbe1fd50b9',
'godot-pixel-cutout-rig/cutout_rig/parts/torso.png':'37e97a6478cfcc9e71df5f58eeafd8d6b3d9a4c8'
};
for(const [path,hash] of Object.entries(official)){assert.equal(sha(root+path),hash,'Source content changed: '+path)}
const scene=read(root+'gbot-skeleton-reference/player/player.tscn').toString();
const bones=[...scene.matchAll(/\[node name="([^"]+)" type="Bone2D" parent="([^"]+)"[^\]]*\]/g)];
assert.equal(bones.length,16,'Original GBot scene must have 16 Bone2D nodes');
assert.ok(scene.includes('AnimationTree') && scene.includes('Skeleton2D'));
assert.ok((scene.match(/\[sub_resource type="Animation"/g)||[]).length>=5,'Animation resources missing');
const ref=JSON.parse(read('references/rigging/joint-reference-map.json'));
assert.equal(ref.bones.length,16);
const paths=new Set(ref.bones.map(b=>b.path));
let roots=0;
for(const bone of ref.bones){
 if(!paths.has(bone.parentPath))roots++;
 for(const n of [...Object.values(bone.rest_global),...Object.values(bone.local_px)])
  assert.ok(Number.isFinite(n), 'nonfinite point '+bone.name);
}
assert.equal(roots,1,'All descendants should form one skeleton hierarchy');
assert.equal(ref.tavi.measuredJointPoints,null,'Do not invent original Tavi pivot points');
assert.equal(ref.rumo.measuredHipKneeAnkle,null,'Do not invent dinosaur limb measurements');
for(const name of ['torso','head','upper_arm','forearm','thigh','shin','disc_lg','disc_sm'])assert.ok(existsSync(new URL('../'+root+'godot-pixel-cutout-rig/cutout_rig/parts/'+name+'.png',import.meta.url)));
const gd=read(root+'godot-pixel-cutout-rig/cutout_rig/cutout_rig.gd').toString();
assert.ok(gd.includes('class_name CutoutRig')&&gd.includes('AnimationPlayer')&&gd.includes('Sprite2D'));
assert.ok(read(root+'godot-pixel-cutout-rig/LICENSE').toString().includes('MIT License'));
assert.ok(read(root+'gbot-skeleton-reference/README_UPSTREAM.md').toString().includes('MIT License'));
console.log('PASS vendor rig references: 16 connected GBot bones, animation resources, 8 cutout textures, SHA-matched sources, finite pivots, preserved licensing');
