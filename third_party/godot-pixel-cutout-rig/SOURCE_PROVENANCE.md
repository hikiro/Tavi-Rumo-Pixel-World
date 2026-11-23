# Pixel cutout rig — isolated upstream import

Original: https://github.com/haingt-dev/godot-pixel-cutout-rig
License: MIT, Copyright (c) 2026 haingt.dev; exact license included as LICENSE.
Source code, texture assets and demo scenes in this folder retain exact upstream Git blob SHA and content.

This imports an actual rig mechanism and demonstration. The supplied character is **only a stick-figure placeholder**. It is not Tavi, and its humanoid topology does not apply directly to Rumo's nine-layer dinosaur.

To run, open this folder as a Godot 4.7 project and start `demo/rig_demo.tscn` or the project main menu. Keep this third-party copy isolated from the user-approved original Engine V5 files.

Proposed adaptation: rebuild the Tavi part bitmaps from authentic Explorer V2 turnaround images; calibrate shoulder/hip/elbow/knee/ankle joint offsets in source pixel coordinates; add ground-contact constraints and measured root motion. A separate dinosaur topology and jaw/tail pivot attachments are required for Rumo.
