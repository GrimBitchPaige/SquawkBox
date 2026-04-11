extends Area3D

@export var scene_name : StringName
@export var repeatable : bool = false
@export var debug_mode : bool = false

var has_played : bool = false

func _on_body_entered(body: Node3D) -> void:
	print('player entered dialogue area')
	SquawkBoxManager.load_scene(scene_name, debug_mode)


func _on_area_entered(area: Area3D) -> void:
	print('player entered dialogue area')
	SquawkBoxManager.load_scene(scene_name, debug_mode)
