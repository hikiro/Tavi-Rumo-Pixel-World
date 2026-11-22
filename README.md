# Tavi & Rumo — Pixel World

A playable pixel-world recovery workspace for **Tavi**, the boy explorer, and **Rumo**, his friendly dinosaur companion.

## Source integrity
This repository stores **reconstructed** material from the November 2026 Tavi–Rumo project conversation. The historically approved **DINO Engine V5** is a locked baseline. Its original source ZIP has not been recovered here. Reconstructed files must **not** be labeled as the original Engine V5 or replace it.

## Current recovery scope
- Recovered project identity, animation requirements, quality gates and developer notes.
- Browser preview: `index.html` (in development on this recovery branch).
- Python/Pillow local reconstruction in the downloadable recovery ZIP, not yet committed here.
- Physics, character art, native Godot project and full directional animation require independent inspection.

## Character/action goals
Tavi: idle, walk, run, jump, punch, block, fireball, fall, turn left/right.
Rumo: follow, idle, walk, run, chase, roar, lunge, jump.
Both require foot contacts, stable limb connectivity, real weight transfer, correct camera/world-coordinate behavior and no intersections.

## Historical constraints
- Preserve approved Engine V5 files byte-for-byte if found.
- Treat V6–V12, Nokia Pixel Town and unrelated character experiments as separate branches.
- No claim of original-character fidelity without source comparison.
- Record every QC loop: defect, likely cause, correction, tests executed and outstanding risks.
- Only promote visuals following independent motion/asset QA.

## Run
Open the browser preview file when present. For the archived Python rebuild, extract the companion recovery ZIP and run `python src/engine.py --out previews --frames 240 --fps 24` after installing Pillow. Encoding MP4 requires ffmpeg.
