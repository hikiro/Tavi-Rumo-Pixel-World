import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
const html=readFileSync(new URL('../index.html',import.meta.url),'utf8');
for(const term of ['requestAnimationFrame','drawTavi','drawRumo','drawPortal','restart','T.vy+=760*dt','T.x=clamp','document.querySelectorAll']) assert.ok(html.includes(term),term);
const script=html.match(/<script>([\s\S]*?)<\/script>/)?.[1];
assert.ok(script,'missing script');
new Function(script);
assert.ok(!html.includes('Nokia Pixel Town'),'wrong project asset');
console.log('PASS: standalone HTML source parses and core functions present');