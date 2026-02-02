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
var dialogue_nodes : Array[Node]
var temp_json_save_str : String

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

func nodes_to_json() -> void:
	var export_dict : Dictionary = {"SceneName":scene_name.text}
	var data_dict : Dictionary
	for node in dialogue_nodes:
		data_dict.merge(node.get_data_dict())
	export_dict["data"] = data_dict
	temp_json_save_str = JSON.stringify(export_dict, "\t", false)

func json_to_nodes() -> void:
	var tmp_dict = JSON.parse_string(temp_json_save_str)
	scene_name.text = tmp_dict["SceneName"]
	for key in tmp_dict["data"]:
		var temp = dialogue_node.instantiate()
		temp.resizable = true
		temp.call_deferred("add_characters", character_portraits)
		temp.call_deferred("load_node_data", tmp_dict["data"][key], key)
		dialogue_nodes.append(temp)
		graph.add_child(temp)

func _on_popup_menu_id_pressed(id: int) -> void:
	if id == 0:
		print('add node clicked')
		var temp = dialogue_node.instantiate()
		var add_position : Vector2 = graph.get_local_mouse_position()
		
		temp.position_offset = (add_position + graph.scroll_offset) / graph.zoom
		temp.resizable = true
		temp.call_deferred("add_characters", character_portraits)
		temp.call_deferred("generate_uuid")
		dialogue_nodes.append(temp)
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


func _on_export_btn_pressed() -> void:
	nodes_to_json()


func _on_import_btn_pressed() -> void:
	json_to_nodes()
