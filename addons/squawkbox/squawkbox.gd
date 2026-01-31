@tool
extends EditorPlugin

const AUTOLOAD_NAME = "SquawkBoxManager"

var dock

func _enable_plugin() -> void:
	# Add autoloads here.
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/squawkbox/squawk_manager.gd")

func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_autoload_singleton(AUTOLOAD_NAME)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	var dock_scene = preload("res://addons/squawkbox/squawk_dock.tscn").instantiate()
	
	dock = EditorDock.new()
	dock.add_child(dock_scene)
	
	dock.title = 'SquawkDock'
	#dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UL
	#dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING
	
	dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	dock.available_layouts = EditorDock.DOCK_LAYOUT_HORIZONTAL | EditorDock.DOCK_LAYOUT_FLOATING
	
	add_dock(dock)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_dock(dock)
	dock.queue_free()
