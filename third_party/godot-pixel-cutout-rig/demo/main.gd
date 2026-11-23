class_name MainMenu
extends Control
## Tiny front door: pick which demo to run. Both buttons swap the whole scene tree.
##
## [b]Platformer demo[/b] = the rig riding a real [CharacterBody2D] (the value prop).
## [b]Rig gates demo[/b]  = the keyboard harness that eyeballs the rig in isolation (no physics).

## Scene shown when "Platformer demo" is pressed.
const PLATFORMER := "res://demo/platformer_demo.tscn"
## Scene shown when "Rig gates demo" is pressed.
const RIG_GATES := "res://demo/rig_demo.tscn"


func _on_platformer_pressed() -> void:
	get_tree().change_scene_to_file(PLATFORMER)


func _on_rig_gates_pressed() -> void:
	get_tree().change_scene_to_file(RIG_GATES)
