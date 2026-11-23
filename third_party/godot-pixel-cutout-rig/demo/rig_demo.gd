class_name RigDemo
extends Node2D
## Keyboard harness for eyeballing the [CutoutRig] gates in isolation (no physics).
##
##   1/2/3  play idle / walk / rot_torture       S  toggle discrete-angle snap
##   F      flip facing (scale.x mirror)         Z/X spin ForearmFront -/+ 60deg
##   C/V    spin ThighFront -/+ 50deg            R  reset to idle
##
## A mid-value background is used on purpose (no dark-bg crutch) so silhouette separation is judged
## honestly. Run with `--shoot` to capture a sequence of gate frames to `res://.captures/rig_demo/`
## and quit — handy for before/after comparisons when you swap in your own art.

var _clip: String = "idle"
var _snap: bool = false

@onready var _rig: CutoutRig = $CutoutRig
@onready var _label: Label = $UI/Label


func _ready() -> void:
	_refresh()
	if "--shoot" in OS.get_cmdline_user_args():
		await _shoot_sequence()


func _shoot_sequence() -> void:
	## Grab viewport frames across all gates into res://.captures/rig_demo/, then quit. Static frames
	## prove the structural gates (no-tear, draw-order, readability) + the snap pose A/B; temporal
	## shimmer is the live eyeball.
	var dir := ProjectSettings.globalize_path("res://.captures/rig_demo/")
	DirAccess.make_dir_recursive_absolute(dir)
	_rig.pose_at("idle", 1.2)
	await _grab(dir + "01_idle.png")
	for i in 4:
		var t := i * 0.2
		_rig.pose_at("walk", t)
		await _grab(dir + "02_walk_t%02d.png" % int(round(t * 100)))
	_rig.pose_at("rot_torture", 0.75)
	await _grab(dir + "06_torture_fwd.png")
	_rig.pose_at("rot_torture", 2.25)
	await _grab(dir + "07_torture_back.png")
	_rig.spin_joint("ForearmFront", 60)
	await _grab(dir + "08_spin_forearm.png")
	_rig.spin_joint("ThighFront", 50)
	await _grab(dir + "09_spin_thigh.png")
	_rig.pose_at("walk", 0.1)
	_rig.set_discrete_snap(false)
	await _grab(dir + "10_walk_continuous.png")
	_rig.set_discrete_snap(true, 12)
	await _grab(dir + "11_walk_snap12.png")
	_rig.set_discrete_snap(false)
	_rig.pose_at("idle", 1.2)
	_rig.toggle_facing()
	await _grab(dir + "12_facing_left.png")
	get_tree().quit()


func _grab(path: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("[shot] ", path)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match (event as InputEventKey).keycode:
		KEY_1:
			_play("idle")
		KEY_2:
			_play("walk")
		KEY_3:
			_play("rot_torture")
		KEY_R:
			_play("idle")
		KEY_S:
			_snap = not _snap
			_rig.set_discrete_snap(_snap)
		KEY_F:
			_rig.toggle_facing()
		KEY_Z:
			_rig.spin_joint("ForearmFront", -60)
			_clip = "pose"
		KEY_X:
			_rig.spin_joint("ForearmFront", 60)
			_clip = "pose"
		KEY_C:
			_rig.spin_joint("ThighFront", -50)
			_clip = "pose"
		KEY_V:
			_rig.spin_joint("ThighFront", 50)
			_clip = "pose"
		_:
			return
	_refresh()


func _play(clip: String) -> void:
	_clip = clip
	_rig.play_clip(clip)


func _refresh() -> void:
	var snap_txt := "ON(%d)" % _rig._snap_steps if _snap else "off"
	_label.text = (
		"CUTOUT RIG DEMO — stick figure @112px\nclip: %s    snap: %s\n\n" % [_clip, snap_txt]
		+ "[1] idle  [2] walk  [3] torture  [R] reset\n"
		+ "[S] discrete-snap  [F] flip facing\n"
		+ "[Z/X] spin forearm  [C/V] spin thigh"
	)
