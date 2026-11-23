class_name PlatformerDemo
extends CharacterBody2D
## Minimal platformer body that drives a [CutoutRig] — the rig riding a real body.
##
## This is the whole value prop in ~35 lines: feed the rig ONE int (facing) and ONE bool (moving)
## and the idle/walk clips + the facing mirror happen for free. No state machine, no form-swap (that
## is game-specific). Uses the project's "move_*" + "jump" actions so it runs with the bundled input
## map. Drives the [CutoutRig] child node named "Rig".

## Horizontal move speed in px/s.
const SPEED := 90.0
## Initial jump velocity (negative = up) in px/s.
const JUMP_VELOCITY := -260.0

## Project default gravity (px/s^2), read once so the demo honours the project setting.
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)
## Last non-zero horizontal facing (+1 right, -1 left), so the rig keeps facing while idle.
var _facing: int = 1

## The cutout rig this body animates. Lives as a child Node2D using cutout_rig.gd.
@onready var _rig: CutoutRig = $Rig


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED
	move_and_slide()

	if dir != 0.0:
		_facing = 1 if dir > 0.0 else -1
	_rig.set_facing(_facing)
	_rig.set_locomotion(absf(velocity.x) > 5.0)
