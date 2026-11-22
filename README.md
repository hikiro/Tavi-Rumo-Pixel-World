# Portalbound: Tavi & Rumo — recovery build

A browser-playable **reconstruction** of the Tavi & Rumo pixel-world adventure, built from the recoverable project brief and supplementary recovery code. This is **not the original DINO Engine V5** and should not be mistaken for an approved character rig.

## Preview
Open [index.html](index.html) locally in any modern desktop browser. GitHub's file viewer shows the source, so use the **Download raw file** action and open it to play. No dependencies, bundler, account, or server are required.

Keyboard: **A/D** or **Left/Right** to move; **W/Space** to jump; **F** to throw a fireball; **J** to punch; **K** to block. Rumo follows Tavi. Reach the glowing portal on the right. Touch buttons are also included.

## What is actually implemented
- Procedural pixel-art Tavi and Rumo; simple interactive states.
- Side-scrolling camera, ground gravity, basic jump, attack and blocking.
- Follower behavior and a portal-completion state.
- Source-parse CI and transparent recovery / QA records.

## Historical source vs new reconstruction
The user-approved historical baseline was named **DINO Engine V5**. Previously described assets included a 96-pixel / 19-part Tavi Explorer V2 turnaround and a nine-layer Rumo rig with specific pivots. These files themselves have not been recovered here. See [recovery provenance](docs/RECOVERY_PROVENANCE.md) and [QC handover](docs/QC_AND_HANDOVER.md) before treating this as a production build.

The current build is a prototype, **not** a complete physics engine, full game, or verified recreation of the approved sprites. Binary animation renders and ZIP assets available in the conversation are not yet uploaded as individual GitHub files.

## Local test
```sh
npm test
```

This is a **static JavaScript source check**, not a runtime play-test. Review and approval remain necessary before replacing the V5 baseline.

## Next
Recover the exact V5 ZIPs/rigs, preserve them unchanged under `legacy/original-v5/`, compare joint positions and silhouettes, restore four-direction motion, and run actual per-frame and interactive QA before promotion.
