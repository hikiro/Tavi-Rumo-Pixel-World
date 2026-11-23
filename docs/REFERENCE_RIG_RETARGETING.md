# Correct reference-based rigging direction — 23 November 2026

## Decision
Reject `experimental/rigging-rebuild-v0.2` as the baseline for the original characters. It uses fabricated shapes and simplistic gait despite passing geometry tests. Do **not** copy its new drawn characters or replace the original Engine V5.

## Authoritative recovered target identity
Source: [Portalbound Master Production Register](https://docs.google.com/spreadsheets/d/18d4NHrfaWBcq4vfOsUlTuwVOQwyT73lN/edit), captured 2026-11-22.

- **Tavi:** yellow expedition helmet, red jacket, blue trousers. The later `DINO_RIG_REBOOT_R1` is the current separate 2.5D human rig prototype with 18 actions; NOT artistically approved. Its known gaps: back-facing art, sleep/lying and collapse contacts.
- **Rumo:** green dinosaur body, **orange** dorsal spikes, maintain original V5 silhouette and palette. Original nine layers were individually pivoted; they were NOT an articulated parent-child skeleton.
- **Engine:** DINO Engine V5 original six-file core is immutable. Extend outside it only.
- Approved source coordinates reported for Rumo's original layer-local cutouts: head/jaw (20,21) and tail (43,29). These **cannot be used as world coordinates** until original sprite origin and scale are recovered.

## Authored source available now
1. `third_party/gbot-skeleton-reference/player/player.tscn`: actual Godot Skeleton2D rig with 16 connected Bone2D joints, real preauthored animations and original GBot image atlas. Use as a **topology/reference mechanism only**. It is not pixel Tavi or dinosaur Rumo.
2. `third_party/godot-pixel-cutout-rig/`: MIT licensed example with pivot-centered sprites, disc seam covers, depth ordering, native Godot demos and reversible mirroring for side profile. Demo art is placeholder stick figure; no built-in IK or foot lock.
3. `references/rigging/joint-reference-map.json`: measured local and rest-global 16 GBot bone points. Tavi/Rumo unknown anchors explicitly null.

## Correct plan
1. Recover original files named in `ORIGINAL_ARTIFACT_RECOVERY_MANIFEST.json` and verify SHA-256 before extraction. The register says they are **local only, not on Drive**, so Drive metadata does not recover their bytes.
2. Extract Tavi's 96-pixel turnaround and R1 joint layers if supplied. For each direction, annotate an actual measured 2D pivot on each original separated part: head-neck, neck-torso, shoulders-elbows-wrists, hips-knees-ankles, and accessory anchors (helmet, backpack). Preserve recognizable approved art and camera depth.
3. Extract original nine Rumo image layers, audit source sprite pixel bounds and each layer origin. Convert fixed pivots into a true parent-child hierarchy: world root -> pelvis -> torso -> neck -> head -> jaw; articulated tail chain; forearm; left/right leg and foot contacts. Implement source-to-world pivot conversion tests, not guessed coordinate offsets.
4. Retarget proven Godot cutout/Bone2D mechanics **without overwriting source art**. Evaluate MIT `fl-wxiao/godot-rigkit` for contact/foot lock only after an actual native Godot runtime test; do not claim imported/working yet.
5. Motion quality gate: 60 fps contact and moving-world foot lock, stable length, believable weight shift, independent head/shoulder/hip ground contacts on fall, correct direction-specific views, no overlaps. At least 2 independent QC/repair loops. Reviewer must reject poor resemblance even if numeric tests pass.

## Current status
**References imported; original character retargeting BLOCKED by missing approved original local ZIP files.** Nothing in this repository is an approved replacement for original V5 nor the R1 human rig. GitHub source-hash/metadata tests pass, but native Godot animation playback is not verified.
