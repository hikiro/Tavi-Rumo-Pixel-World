# QA and handover — recovery V0.1

## Initial historical recovery
- Reviewed previous project notes and distinguished original V5 claims from source that is actually present.
- Found no mounted original V5 ZIPs, dinosaur source layers or Godot build. The reconstructed engine cannot be approved as a faithful port.

## Browser prototype
- Action: built a standalone HTML Canvas world with Tavi player, Rumo companion, walking, jump, block, punch, fireball, hazards, camera and a portal.
- Likely defects to audit: foot sliding in time-driven gait, fall-cycle timing, mechanical limb fidelity, out-of-frame sprites, Rumo collision, player/hazard health depletion rate.
- Tests: GitHub commit acknowledged by connector; inspect fetched source next. Live graphical browser playback and automated physics tests are **not yet verified**.
- Limit: no original V5 asset likeness check, no four-direction sprites, no matching legacy engine measurements, no validated game collision harness.
- Approval: **RECOVERY PREVIEW ONLY**, not promotion to approved V5.

## Independent recovered video package (not committed here)
- Prior local recovery 240 frames / 24 fps / 960×540 / 10 s preview was ffprobe-validated.
- Its QA log reported a title-card crossing, jump leg stretch and Tavi/Rumo overlap, corrected in the follow-up render.
- Only sampled contact-sheet views were visually reviewed. Every intermediate frame, pivots, grounded feet, sound and gameplay physics are unverified.

## Required next QC gate
1. Retrieve exact original V5 rigs and source.
2. Run original-vs-recovered silhouette and keypoint comparison.
3. Inspect all locomotion contact frames and front/back/left/right transitions.
4. Run browser smoke test and replay deterministic inputs (jump, left-right, blocking, hazard, portal).
5. Only then promote a candidate to the approved baseline.

## Regression rules
Do not claim an MP4 validates gameplay, do not claim source descriptions prove sprites are recovered, and keep original approved content byte-for-byte.