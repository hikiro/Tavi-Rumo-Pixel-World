# Tavi & Rumo rigging recovery — V0.2

## From the previous chats (reported history, not original bytes)
- The approved **DINO Engine V5** is the historical baseline. Its original asset/layer files and source archive are not currently available.
- Tavi Explorer V2 was described as a **96-pixel 19-editable-part-per-direction turnaround**, 14-color palette, with 48-pixel compatibility sprites.
- Rumo's nine reported visual layers: tail, rear leg, front leg, neck, torso, spikes, head, jaw, forearm.
- Reported source-layer pivots: head/jaw **(20,21)** and tail **(43,29)**; reference coordinate systems unverified.
- Prior code architecture names: `game_world.js`, `motion_14_8bit.js`, `dinoLayers`, `explorerLayers`, `drawDino`, `drawHero`.
- Desired action vocabulary: Tavi idle/walk/run/jump/punch/block/fireball/fall/turn; Rumo idle/walk/chase/roar/lunge/jump/follow.
- Quality requirements: stable shoulders/hips/head, correctly oriented limbs, attached joints, COM-weight transfer, grounded feet, world-correct camera, no intersection; repairs logged after every QC pass.

## What was recreated
- `rigging.mjs`: a **new** deterministic geometric rig/pose engine with analytic two-bone IK and declared layer slots.
- `rig-lab.html`: a live-selectable action laboratory that draws both provisional characters and overlays joint indicators.
- `rig.test.mjs`: checks limb length, finite joints, metadata, and reachable foot targets over 1,680 generated poses.
- Standalone package in the ChatGPT conversation also contains the larger implementation, offline-rig contact sheet and 128-frame MP4 preview.

## Fidelity and test restrictions
- The nine Rumo labels and historical pivot numbers are retained, **not** recovered source bitmaps or independently verified exact pixel-space transforms.
- The Tavi 19 layer **names** and all procedural character drawings are provisional. A data list is not the original 19-layer art or complete runtime skinning.
- Neither current reconstructed rig reproduces all four original sprite directions. Live game collision, COM shift, moving ground-anchor compensation and root motion remain to implement.
- The repo preview was not live-tested in the current browser environment (render automation blocked). The separate local contact sheet and 128-frame MP4 were rendered and visually inspected; geometry tests passed on the local full version.
- Original-vs-new silhouette and motion certification **blocked** until authentic V5 files are supplied.

## QC log
| Action | Defect | Cause | Repair | Tests | Remaining |
|---|---|---|---|---|---|
| Initial IK test | Zero-distance request collapsed a chain | Division by near-zero produced zero direction | Added fallback direction before analytic IK | Re-ran all 1,680 pose samples; PASS (local) | No real V5 source to compare |
| Visual contact-sheet review | Tavi idle legs appeared permanently crouched | Hip at -22 while thigh+shin length 33 | Moved reconstructed Tavi hip to -29 | Rebuilt 8-pose contact sheet, 128-frame video; full geometry test PASS | Ground-locked gait still not established |
| Browser render attempt | Chromium blocked localhost and local-file screenshot capture | Sandbox administrator policy | Created independent Pillow contact-sheet and MP4 | Video ffprobe 128 frames, 16 fps, 960×540 | Live rig-lab playback unverified |

## Gate
**RECONSTRUCTION / NOT PROMOTED**. Keep the historical Engine V5 baseline untouched if recovered.