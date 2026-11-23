class_name CutoutRig
extends Node2D
## A code-built 2D cutout (paper-doll) rig for pixel-art characters.
##
## WHAT IT IS
## A [CutoutRig] node builds a hip-rooted [Node2D] BONE hierarchy of [Sprite2D] parts entirely in
## code, then drives it with a code-generated [AnimationPlayer] (idle / walk / a joint-stress test
## clip). Each bone is a bare [Node2D]; the limb art is a child [Sprite2D]. Animations key ONLY bone
## ROTATION (plus a small hip bob) — so the same clips play on ANY character whose parts follow the
## contract below. Swap the PNGs in `parts/`, keep the pivots, and the motion comes for free.
##
## THE PARTS CONTRACT (read this before swapping in your own art)
## The rig loads 8 textures from [constant PARTS_DIR]:
##     torso, head, upper_arm, forearm, thigh, shin, disc_lg, disc_sm   (all `.png`)
## Each part is a pre-padded bitmap whose PIVOT (the joint it rotates around) sits at the EXACT
## CENTRE of its canvas. The rig sets every [Sprite2D] to `centered = true` with zero offset, so the
## bone origin lands exactly on the joint and rotation pivots cleanly with no per-node offset math.
## Keep canvas dimensions EVEN so `size / 2` is an integer pixel (sharp under nearest filtering).
##   - torso pivots at the PELVIS (bottom) and extends UP.
##   - head pivots at the NECK (bottom).
##   - upper_arm / forearm / thigh / shin pivot at the upper joint (shoulder / elbow / hip / knee).
##   - disc_lg / disc_sm are small "joint dot" discs centred on their own pivot; they are drawn ON
##     TOP of a limb to mask the seam where two parts meet at any swing angle.
## A regenerator for placeholder parts lives in `tools/make_stick_parts.py`. Sizes there feed the
## bone-length constants below — if you change one, change the other.
##
## FAR-LIMB ECONOMY (no extra art, no flip_h)
## The far arm/leg reuse the SAME textures as the near side, just tinted darker + cooler via
## [member CanvasItem.modulate] ([constant FAR]). The opposite-phase swing comes purely from bone
## rotation in the walk clip — never from `flip_h`. Facing is a whole-rig `scale.x` mirror.
##
## THE ONE EXTENSION POINT (secondary motion — described, not implemented)
## To add springy secondary motion (hair, a cape, jiggle), add an UNKEYED leaf bone as a child of
## whatever drives it (e.g. a "Hair" bone under "Head") and give it its own [Sprite2D] part. Because
## no animation track touches that bone, you can own its rotation each frame. In [method _process]
## (which already runs at a high [member Node.process_priority] AFTER the [AnimationPlayer]), run a
## ~30-line damped-spring follower: track the leaf bone's parent's world angle/velocity, push the
## leaf toward a target with `spring` and `damping` constants, integrate, and write the result
## to the leaf's `rotation`. It trails and overshoots the keyed motion for a lively feel — all
## without a single extra keyframe. This file intentionally ships WITHOUT that spring; the hook is
## the unkeyed-leaf-bone + the post-anim [method _process] slot.

## Folder the 8 part textures are loaded from. Drop your own art here (same filenames, same pivots).
const PARTS_DIR := "res://cutout_rig/parts/"

## Bone lengths = pivot-to-joint, in pixels. MUST match the part generator (`make_stick_parts.py`).
## Sized for a ~112px figure (head 18 + torso 38 + thigh 28 + shin 28 = 112).
const L_TORSO := 38
const L_UARM := 24
const L_THIGH := 28

## Far-limb tint: the same texture, darkened + cooled so the back arm/leg reads as further away.
## NEVER flip the texture for the far side — opposite-phase swing comes from bone rotation instead.
const FAR := Color(0.80, 0.80, 0.86)
## Near-limb tint: untouched (full white modulate).
const NEAR := Color(1.0, 1.0, 1.0)

var hip: Node2D
# bone_name -> Node2D (used for animation track paths + joint-spin lookups by name)
var bones: Dictionary = {}
var _anim: AnimationPlayer
var _facing: int = 1
var _snap_on: bool = false
var _snap_steps: int = 12


func _ready() -> void:
	process_priority = 500  # snap (_process) must run AFTER the AnimationPlayer applied rotation
	_build_skeleton()
	_build_anims()
	_anim.play("idle")


# --- skeleton build (draw-order = add order) ---


func _bone(parent: Node2D, bone_name: String, pos: Vector2) -> Node2D:
	var b := Node2D.new()
	b.name = bone_name  # deterministic name -> deterministic anim track path
	b.position = pos
	parent.add_child(b)
	bones[bone_name] = b
	return b


func _part(bone: Node2D, tex: String, tone: Color) -> void:
	## The bone's own limb sprite. Parts are pre-padded so pivot == texture centre, hence
	## centered=true + zero offset => the bone origin sits exactly on the joint (no offset math).
	var s := Sprite2D.new()
	s.texture = load(PARTS_DIR + tex + ".png")
	s.modulate = tone
	bone.add_child(s)


func _disc(bone: Node2D, tex: String, tone: Color) -> void:
	## Ball-joint disc at the bone's pivot (0,0), drawn ON TOP of the limb (added after _part) to
	## mask the joint seam at any swing angle.
	var s := Sprite2D.new()
	s.texture = load(PARTS_DIR + tex + ".png")
	s.modulate = tone
	bone.add_child(s)


func _build_skeleton() -> void:
	hip = _bone(self, "Hip", Vector2.ZERO)
	_disc(hip, "disc_lg", NEAR)  # pelvis hub

	# FAR LEG — first child of Hip -> lowest z (behind torso)
	var tb := _bone(hip, "ThighBack", Vector2(-2, 0))
	_part(tb, "thigh", FAR)
	_disc(tb, "disc_lg", FAR)
	var sb := _bone(tb, "ShinBack", Vector2(0, L_THIGH))
	_part(sb, "shin", FAR)
	_disc(sb, "disc_sm", FAR)

	# TORSO — second child of Hip
	var torso := _bone(hip, "Torso", Vector2.ZERO)
	#   far arm FIRST under torso -> behind the trunk sprite
	var ab := _bone(torso, "ArmBack", Vector2(-3, -34))
	_part(ab, "upper_arm", FAR)
	_disc(ab, "disc_lg", FAR)
	var fb := _bone(ab, "ForearmBack", Vector2(0, L_UARM))
	_part(fb, "forearm", FAR)
	_disc(fb, "disc_sm", FAR)
	#   trunk sprite — drawn after far arm (in front of it), before near arm (behind it)
	_part(torso, "torso", NEAR)
	#   near arm AFTER trunk -> in front of trunk
	var af := _bone(torso, "ArmFront", Vector2(3, -34))
	_part(af, "upper_arm", NEAR)
	_disc(af, "disc_lg", NEAR)
	var ff := _bone(af, "ForearmFront", Vector2(0, L_UARM))
	_part(ff, "forearm", NEAR)
	_disc(ff, "disc_sm", NEAR)
	#   head LAST under torso -> on top
	var head := _bone(torso, "Head", Vector2(0, -L_TORSO))
	_part(head, "head", NEAR)

	# NEAR LEG — last child of Hip -> in front of torso
	var tf := _bone(hip, "ThighFront", Vector2(2, 0))
	_part(tf, "thigh", NEAR)
	_disc(tf, "disc_lg", NEAR)
	var sf := _bone(tf, "ShinFront", Vector2(0, L_THIGH))
	_part(sf, "shin", NEAR)
	_disc(sf, "disc_sm", NEAR)


# --- animations (key ONLY bone rotation/position) ---


func _rot_path(bone_name: String) -> NodePath:
	return NodePath(str(get_path_to(bones[bone_name])) + ":rotation")


func _track_rot(anim: Animation, bone_name: String, keys: Array) -> void:
	## keys = [[time_s, degrees], ...] — linear, radians under the hood.
	var t := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t, _rot_path(bone_name))
	anim.track_set_interpolation_type(t, Animation.INTERPOLATION_LINEAR)
	for k in keys:
		anim.track_insert_key(t, k[0], deg_to_rad(k[1]))


func _track_pos(anim: Animation, bone_name: String, keys: Array) -> void:
	## keys = [[time_s, Vector2], ...] — for the Hip walk bob.
	var t := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t, NodePath(str(get_path_to(bones[bone_name])) + ":position"))
	anim.track_set_interpolation_type(t, Animation.INTERPOLATION_LINEAR)
	for k in keys:
		anim.track_insert_key(t, k[0], k[1])


func _new_anim(length: float) -> Animation:
	var a := Animation.new()
	a.length = length
	a.loop_mode = Animation.LOOP_LINEAR
	return a


func _make_idle() -> Animation:
	## Breathe around a slightly OPEN stance. A pure-90 profile with arms straight down + feet
	## together collapses every limb into a vertical pole — so the DISPLAYED idle splays (near limbs
	## forward, far limbs back) to read as a figure. (The straight A-pose stays the part-CUTTING
	## pose; sign convention from the walk: arm/thigh negative = forward / +x.)
	var a := _new_anim(2.4)
	_track_rot(a, "ArmFront", [[0, -8], [1.2, -11], [2.4, -8]])
	_track_rot(a, "ArmBack", [[0, 4], [1.2, 1], [2.4, 4]])
	_track_rot(a, "ForearmFront", [[0, -8], [1.2, -11], [2.4, -8]])
	_track_rot(a, "ForearmBack", [[0, -4], [2.4, -4]])
	_track_rot(a, "ThighFront", [[0, -6], [2.4, -6]])
	_track_rot(a, "ThighBack", [[0, 8], [2.4, 8]])
	_track_rot(a, "ShinFront", [[0, 4], [2.4, 4]])
	_track_rot(a, "ShinBack", [[0, 2], [2.4, 2]])
	_track_rot(a, "Torso", [[0, 0], [1.2, 3], [2.4, 0]])
	_track_rot(a, "Head", [[0, 0], [1.2, -2], [2.4, 0]])
	_track_pos(a, "Hip", [[0, Vector2.ZERO], [1.2, Vector2(0, -1)], [2.4, Vector2.ZERO]])
	return a


func _make_walk() -> Animation:
	var a := _new_anim(0.8)
	# legs — opposite phase (near +theta / far -theta)
	_track_rot(a, "ThighFront", [[0, 18], [0.4, -18], [0.8, 18]])
	_track_rot(a, "ThighBack", [[0, -18], [0.4, 18], [0.8, -18]])
	_track_rot(a, "ShinFront", [[0, 8], [0.4, 28], [0.8, 8]])
	_track_rot(a, "ShinBack", [[0, 28], [0.4, 8], [0.8, 28]])
	# arms — counter-swing to same-side leg
	_track_rot(a, "ArmFront", [[0, -14], [0.4, 14], [0.8, -14]])
	_track_rot(a, "ArmBack", [[0, 14], [0.4, -14], [0.8, 14]])
	_track_rot(a, "ForearmFront", [[0, -10], [0.4, -18], [0.8, -10]])
	_track_rot(a, "ForearmBack", [[0, -18], [0.4, -10], [0.8, -18]])
	_track_rot(a, "Torso", [[0, 2], [0.4, -2], [0.8, 2]])
	# hip bob at 2x stride frequency
	_track_pos(
		a,
		"Hip",
		[
			[0, Vector2.ZERO],
			[0.2, Vector2(0, -2)],
			[0.4, Vector2.ZERO],
			[0.6, Vector2(0, -2)],
			[0.8, Vector2.ZERO]
		]
	)
	return a


func _make_torture() -> Animation:
	## Hands-free seam stress: sweep joints through wide ranges; watch for any tear at the seams.
	var a := _new_anim(3.0)
	_track_rot(a, "ForearmFront", [[0, 0], [0.75, 90], [1.5, 0], [2.25, -90], [3.0, 0]])
	_track_rot(a, "ThighFront", [[0, 0], [0.75, 55], [1.5, 0], [2.25, -55], [3.0, 0]])
	_track_rot(a, "ShinFront", [[0, 0], [1.5, 70], [3.0, 0]])
	_track_rot(a, "ArmFront", [[0, 0], [1.5, 60], [3.0, 0]])
	_track_rot(a, "Head", [[0, 0], [0.75, 25], [1.5, 0], [2.25, -25], [3.0, 0]])
	return a


func _build_anims() -> void:
	_anim = AnimationPlayer.new()
	_anim.name = "Anim"
	add_child(_anim)
	var lib := AnimationLibrary.new()
	lib.add_animation("idle", _make_idle())
	lib.add_animation("walk", _make_walk())
	lib.add_animation("rot_torture", _make_torture())
	_anim.add_animation_library("", lib)


# --- discrete-angle snap (anti-shimmer option) ---


func _process(_dt: float) -> void:
	## Optional anti-shimmer experiment: quantise every bone's rotation to N fixed angles. Runs after
	## the AnimationPlayer (process_priority 500) so it overrides the continuous value each frame.
	## If it does not visibly take, flip _anim.callback_mode_process to PHYSICS so idle _process is
	## guaranteed to run after — left as a documented fallback.
	## (This is also the slot for the secondary-motion spring described in the header.)
	if not _snap_on:
		return
	var step := TAU / float(_snap_steps)
	for n in bones:
		var b: Node2D = bones[n]
		b.rotation = round(b.rotation / step) * step


# --- public API ---


func play_clip(clip: String) -> void:
	## Play a clip by name ("idle" / "walk" / "rot_torture"). Idempotent — safe to call every frame;
	## it will not restart a clip that is already current.
	if _anim.current_animation != clip:
		_anim.play(clip)


func set_facing(dir: int) -> void:
	## Set absolute facing: +1 faces right, -1 faces left. Mirrors the whole rig via the hip
	## `scale.x`. A `dir` of 0 (or no change) is ignored. Drive this from your character's facing.
	if dir == 0 or dir == _facing:
		return
	_facing = dir
	hip.scale.x = float(dir)


func set_locomotion(moving: bool) -> void:
	## Convenience: play "walk" while moving, otherwise "idle".
	play_clip("walk" if moving else "idle")


func pose_at(clip: String, t: float) -> void:
	## Freeze a clip at time `t` seconds (for static screenshots / debugging a single pose).
	_anim.play(clip)
	_anim.seek(t, true)
	_anim.pause()


func set_discrete_snap(on: bool, steps: int = 12) -> void:
	## Toggle discrete-angle snapping. When `on`, every bone's rotation is quantised to `steps`
	## evenly spaced angles each frame — an option for reducing rotated-pixel shimmer.
	_snap_on = on
	_snap_steps = steps


func spin_joint(bone_name: String, degrees: float) -> void:
	## Stop any clip and pose a single named bone to an absolute angle (for static seam checks).
	## Bone names: Hip, Torso, Head, ArmFront/Back, ForearmFront/Back, ThighFront/Back, ShinFront/Back.
	if _anim.is_playing():
		_anim.stop()
	if bones.has(bone_name):
		bones[bone_name].rotation = deg_to_rad(degrees)


func toggle_facing() -> void:
	## Flip facing left<->right (whole-rig `scale.x` mirror).
	_facing = -_facing
	hip.scale.x = float(_facing)


func get_snap_state() -> bool:
	## Return whether discrete-angle snapping is currently on.
	return _snap_on
