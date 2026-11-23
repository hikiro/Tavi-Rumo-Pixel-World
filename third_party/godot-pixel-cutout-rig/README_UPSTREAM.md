# Godot Pixel Cutout Rig

> Animate a 2D pixel character in **Godot 4.7** by *rigging cutout parts* — a `Node2D` bone tree
> driven by an `AnimationPlayer` that keys **only bone rotation** — instead of hand-drawing every
> frame. No mesh deform, no skinning weights, no third-party runtime, no import step.

![Godot 4.7](https://img.shields.io/badge/Godot-4.7-478cbf?logo=godotengine&logoColor=white)
![GDScript](https://img.shields.io/badge/GDScript-pure-355570)
![License: MIT](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/version-0.1.0-blue)
![Status: early](https://img.shields.io/badge/status-early%2Fexperimental-orange)

<p align="center">
  <img src="docs/media/walk.gif" alt="Stick-figure cutout rig walking" height="320">
</p>

<p align="center">
  <img src="docs/media/showcase.png" alt="idle · walk · joint-stress · mirror facing" width="760">
</p>

> ⚠️ **This project is early and rough.** It's a fresh, nascent starter with real gaps and things
> we simply haven't researched yet (see [Status & honest limitations](#status--honest-limitations)).
> The placeholder above is a deliberately crude stick figure — *you bring the real art*. Feedback,
> bug reports, questions, and PRs are all genuinely welcome, including "you got X wrong."

---

## Why this exists

Animation is the wall most solo and non-animator devs hit in 2D. Hand-drawn frame-by-frame is
gorgeous but slow and skill-gated; AI image models can't keep a character consistent from frame to
frame. A **cutout rig** turns animation into *systems work*: cut your character into parts **once**,
then move bones with keyframes + a little code. One rig drives many clips — you never redraw the same
limb twelve times.

This repo is the **minimal, dependency-free, Godot-native** take on that, with a stick-figure
placeholder so it animates the instant you press Play.

## What it does

- Builds a hip-rooted bone tree of `Sprite2D` parts **in code** — no manual scene wiring.
- Ships `idle`, `walk`, and a `joint-stress` clip, all authored by keying bone **rotation**.
- **Stays crisp under nearest filtering**: rigid part rotation never resamples a part's pixel
  interior (the whole reason it isn't mesh-skinning).
- Correct near/far depth from pure **scene-tree order** — zero `z_index`, zero `RemoteTransform2D`.
- **Seam-free joints** at extreme angles (rounded caps + ball-joint discs + under-draw) — see the
  *joint-stress* panel above.
- Whole-rig facing **mirror**; far limbs reuse the near textures **darkened** (no extra art, no
  `flip_h`).
- An optional discrete-angle **anti-shimmer** snap.
- One designed **extension point** for springy secondary motion (hair, a cape) — described, ~30 lines
  for you to wire.

## Quickstart

1. Clone this repo.
2. Open the folder in **Godot 4.7** (first open generates `.import` / `.uid` files).
3. Press **Play** — the platformer demo runs on the placeholder: `A`/`D` to walk, `Space` to jump.
   The rig auto-picks idle vs walk and mirrors its facing.
4. Want the raw mechanism with no physics? Play `demo/rig_demo.tscn` — a keyboard harness:
   `1`/`2`/`3` = idle / walk / joint-stress, `F` = flip facing, `S` = anti-shimmer snap.

## Use it in your project

Copy the **`cutout_rig/`** folder into your project (it has zero external dependencies). Add a
`Node2D`, attach `cutout_rig.gd` (`class CutoutRig`), and drive it with **one int and one bool**:

```gdscript
extends CharacterBody2D

@onready var _rig: CutoutRig = $CutoutRig

func _physics_process(_delta: float) -> void:
    # ... your movement sets velocity ...
    if velocity.x != 0.0:
        _rig.set_facing(1 if velocity.x > 0.0 else -1)  # +1 right, -1 left
    _rig.set_locomotion(absf(velocity.x) > 1.0)         # walk while moving, else idle
```

That's the whole integration. Full API:

| Method | Does |
|---|---|
| `set_locomotion(moving: bool)` | Play `walk` while moving, else `idle` (the common case). |
| `play_clip(name: String)` | Play any clip by name; idempotent, safe every frame. |
| `set_facing(dir: int)` | Absolute facing, `+1`/`-1`; mirrors the whole rig. |
| `toggle_facing()` | Flip facing. |
| `pose_at(clip, t)` | Freeze a clip at time `t` (screenshots / a single pose). |
| `set_discrete_snap(on, steps=12)` | Toggle the anti-shimmer angle snap. |
| `spin_joint(bone, degrees)` | Pose one joint (seam testing). |

Authoring **your own clip** is just adding an `Animation` to the player that keys bone rotation —
walk-through in [`docs/02-rigging-your-character.md`](docs/02-rigging-your-character.md).

## Bring your own character

The rig loads **8 PNGs** from `cutout_rig/parts/`: `torso head upper_arm forearm thigh shin disc_lg
disc_sm`. Each part is padded so the **joint it rotates around sits at the exact centre** of an
even-sized canvas — then a centered `Sprite2D` needs zero offset math (bone origin = texture centre =
joint). Keep the filenames + pivots and the bundled clips just play on your art. Two short guides:

- **[`docs/01-getting-your-art.md`](docs/01-getting-your-art.md)** — the input contract + four ways
  to source the art (draw it, generate it with your own tools, commission it, or rig on the
  placeholder first and swap later).
- **[`docs/02-rigging-your-character.md`](docs/02-rigging-your-character.md)** — cutting + padding
  each part to its pivot, then authoring clips.

## What's inside

```
cutout_rig/            # THE DROP-IN UNIT — copy this folder into your game
  cutout_rig.gd        #   class CutoutRig — builds the bone tree + clips in code (~320 lines)
  parts/*.png          #   the 8 part slots (placeholder stick figure — replace these)
demo/                  # examples (not needed in your project)
  rig_demo.tscn        #   keyboard gate harness — eyeball the rig in isolation
  platformer_demo.tscn #   ~35-line CharacterBody2D driving the rig
tools/                 # OPTIONAL python — pixel-snap a hi-res drawing into clean parts
docs/                  # the two how-to guides + the design rationale + alternatives
```

## The thinking behind the method

These choices aren't vibes — the realistic alternatives (frame-by-frame, `Skeleton2D` mesh-skinning,
Spine, Live2D, DragonBones, and every 2D jiggle/physics addon) were each evaluated and dropped for a
concrete reason. The short version: **reuse the engine where it fits; hand-build only the narrow niche
where nothing reusable exists.**

- **[`docs/WHY-CUTOUT-RIG.md`](docs/WHY-CUTOUT-RIG.md)** — why rigid cutout keeps pixels crisp and
  mesh-deform doesn't.
- **[`docs/ALTERNATIVES.md`](docs/ALTERNATIVES.md)** — every approach evaluated + rejected, and *why
  we don't just pull in an existing physics / rig library*.

## The one extension point: secondary motion

The rig is deliberately rigid, with exactly one designed hook for liveliness. To add springy
secondary motion (hair, a cape), add an **unkeyed leaf bone** (e.g. a `Hair` bone under `Head`) with
its own `Sprite2D`. Because no animation track touches that bone, you own its rotation each frame: in
`_process` (which already runs *after* the `AnimationPlayer`), run a ~30-line damped-spring follower
that trails and overshoots the keyed motion. No extra keyframes. The slot is built in — the spring is
described, not shipped, so you wire it against your real first consumer. See
[`docs/WHY-CUTOUT-RIG.md`](docs/WHY-CUTOUT-RIG.md).

## Status & honest limitations

**Status: early / experimental.** The mechanism is proven on the stick-figure placeholder — joints
don't tear, draw-order holds, idle/walk read, shimmer stays controlled — but it has **not** yet been
battle-tested across many real characters or shipped in a released game. Treat it as a solid starting
point, not a finished framework.

What it deliberately does **not** do (non-goals, not bugs):

- **No mesh deform / skinning / interior squash-&-stretch.** Parts are rigid. Bouncy, blobby,
  heavily-deforming characters are a poor fit.
- **No IK, no state-machine / blend-tree locomotion, no root motion.** You get clip playback + a
  facing mirror; blending (`AnimationTree`) is yours to add.
- **No built-in secondary motion.** The hair/cape spring is *described*, not shipped — one hook.
- **Humanoid-ish / jointed characters only.** Amorphous creatures want procedural animation instead.
- **Rotation shimmer at harsh angles.** Gentle angles read clean; the discrete-snap toggle is a
  mitigation, not a cure.

And aspects we simply **haven't researched yet** — many-rigs-on-screen performance, exotic rig
topologies, automated part-slicing, editor/inspector tooling, and any view other than pure side
profile. There's a lot of room here. If you push on any of it, a PR or a writeup is genuinely
welcome — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Requirements

- **Godot 4.7**.
- Python 3 + **Pillow** + **numpy** — *only* if you use the optional `tools/` helpers.

## Credits & license

Built by [haingt.dev](https://haingt.dev). **MIT** — see [`LICENSE`](LICENSE). Use it, fork it, ship
games with it.
