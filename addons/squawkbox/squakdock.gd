@tool

class_name SquawkDock
extends Control

@onready var right_click_menu : PopupMenu = $PopupMenu
@onready var graph : GraphEdit = $GraphEdit
@onready var edit_btn : TextureButton = $GraphEdit/TopHBox/HBoxLeft/EditSceneNameBtn
@onready var scene_name : Label = $GraphEdit/TopHBox/HBoxLeft/SceneName

#region SceneNameEditPanel
@onready var sn_edit_popup : Control = $GraphEdit/EditSceneNamePopup
@onready var sn_edit_panel : Panel = $GraphEdit/EditSceneNamePopup/EditSceneNamePanel
@onready var sn_edit_box : LineEdit = $GraphEdit/EditSceneNamePopup/VBoxContainer/SceneNameEdit
@onready var sn_accept_btn : Button = $GraphEdit/EditSceneNamePopup/VBoxContainer/HBoxContainer/AcceptSceneNameBtn
@onready var sn_close_btn : Button = $GraphEdit/EditSceneNamePopup/VBoxContainer/HBoxContainer/CloseSceneNameBtn
#endregion

var click_pos : Vector2
var dialogue_node : PackedScene = preload("res://addons/squawkbox/dialogue_node.tscn")
#TODO replace default test values with system to load characters from file
var character_list : Array[StringName] = ["Player", "Sapphos", "Helena"]
var character_portraits = {
	"Player": "res://addons/squawkbox/player.png",
	"Sappho": "res://addons/squawkbox/Lesbian_pride_flag_2018.svg",
	"Helena": "res://addons/squawkbox/default_character_portrait.png"
}

func _ready() -> void:
	edit_btn.set_modulate(Color.GAINSBORO)
	sn_edit_panel.size = sn_edit_popup.size
	#edit_btn.set_modulate(Color.AQUAMARINE)

func _enter_tree() -> void:
	print('docking')


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			print("Right-clicked inside SquawkDock")
			click_pos = event.global_position
			right_click_menu.position = click_pos
			#right_click_menu.visible = true
			right_click_menu.popup()
			right_click_menu.mouse_passthrough = false
		elif event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			print('left mouse')


func _on_popup_menu_id_pressed(id: int) -> void:
	if id == 0:
		print('add node clicked')
		var temp = dialogue_node.instantiate()
		var add_position : Vector2 = graph.get_local_mouse_position()
		#var slot_label : Label = Label.new()
		#var slot_label_2 : Label = Label.new()
		#slot_label.text = 'Dialogue goes here'
		#slot_label_2.text = 'Reply option 1'
		#temp.add_child(slot_label)
		#temp.add_child(slot_label_2)
		
		temp.position_offset = (add_position + graph.scroll_offset) / graph.zoom
		#temp.size = Vector2(100.0, 100.0)
		temp.resizable = true
		#temp.set_slot(0, true, 1, Color.BLACK, true, 1, Color.AQUAMARINE, null, null, false)
		#temp.set_slot(1, true, 1, Color.AQUAMARINE, true, 1, Color.BLACK, null, null, false)
		
		#temp.instantiate()
		temp.call_deferred("add_characters", character_portraits)
		graph.add_child(temp)


func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph.connect_node(from_node, from_port, to_node, to_port)


func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph.disconnect_node(from_node, from_port, to_node, to_port)


func _on_edit_scene_name_btn_pressed() -> void:
	sn_edit_popup.show()


func _on_close_scene_name_btn_pressed() -> void:
	sn_edit_popup.hide()
	sn_edit_box.clear()


func _on_accept_scene_name_btn_pressed() -> void:
	scene_name.text = sn_edit_box.text
	sn_edit_popup.hide()
	sn_edit_box.clear()

func _on_scene_name_edit_text_submitted(new_text: String) -> void:
	scene_name.text = sn_edit_box.text
	sn_edit_popup.hide()
	sn_edit_box.clear()
