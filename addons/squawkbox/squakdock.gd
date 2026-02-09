@tool

class_name SquawkDock
extends Control

@onready var right_click_menu : PopupMenu = $AddNode
@onready var graph : GraphEdit = $GraphEdit
@onready var edit_btn : TextureButton = $GraphEdit/TopHBox/HBoxLeft/EditSceneNameBtn
@onready var scene_name : Label = $GraphEdit/TopHBox/HBoxLeft/SceneName
@onready var export_dialogue : FileDialog = $ExportDialogue
@onready var unsaved_changes : ConfirmationDialog = $UnsavedChanges
@onready var import_dialogue : FileDialog = $ImportDialogue
@onready var import_unsaved_changes : ConfirmationDialog = $ImportUnsavedChangesConfirmation
@onready var unsaved_changes_ind : Label = $GraphEdit/TopHBox/HBoxLeft/UnsavedChangesInd

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
var has_unsaved_changes : bool = false
var is_loading_nodes : bool = false
var node_loaded_num : int = 0
var connections_load_dict : Dictionary

func _ready() -> void:
	edit_btn.set_modulate(Color.GAINSBORO)
	sn_edit_panel.size = sn_edit_popup.size
	unsaved_changes.add_button("Save", false, "save")
	unsaved_changes.custom_action.connect(_save_before_new_scene)
	import_unsaved_changes.add_button("Save and Load", false, "save_and_load")
	import_unsaved_changes.custom_action.connect(_save_changes_load)
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
	temp_json_save_str = ''
	var export_dict : Dictionary = {"SceneName":scene_name.text}
	var data_dict : Dictionary
	for node in dialogue_nodes:
		if data_dict.is_empty():
			data_dict = node.get_data_dict()
		else:
			data_dict.merge(node.get_data_dict())
	
	var i : int = 1
	var connections_dict : Dictionary = {}
	for connection in graph.connections:
		var connection_name : String = 'Connection_%d' % i
		connections_dict[connection_name] = connection
		i += 1
	
	export_dict["data"] = data_dict
	export_dict["connections"] = connections_dict
	temp_json_save_str = JSON.stringify(export_dict, "\t", false)

func json_to_nodes() -> void:
	is_loading_nodes = true
	node_loaded_num = 0
	var tmp_dict = JSON.parse_string(temp_json_save_str)
	scene_name.text = tmp_dict["SceneName"]
	connections_load_dict.clear()
	connections_load_dict = tmp_dict["connections"]
	
	for key in tmp_dict["data"]:
		var temp = dialogue_node.instantiate()
		temp.resizable = true
		temp.call_deferred("add_characters", character_portraits)
		temp.call_deferred("load_node_data", tmp_dict["data"][key], key)
		temp.node_delete.connect(_on_node_deleted)
		temp.dragged.connect(_on_node_offset_changed)
		temp.node_setup_complete.connect(_on_node_setup_complete)
		dialogue_nodes.append(temp)
		temp.call_deferred("set_node_number", (dialogue_nodes.size() - 1))
		graph.add_child(temp)
	
	#load_connections(tmp_dict["connections"])
	toggle_unsaved_changes(false)

func load_connections(connections: Dictionary) -> void:
	print('loading connections')
	for nodes in dialogue_nodes:
		print(nodes.name)
	for key in connections:
		graph.connect_node(connections[key]["from_node"], connections[key]["from_port"], connections[key]["to_node"], connections[key]["to_port"])
	print('done loading connections')

func clear_scene() -> void:
	for d_node in dialogue_nodes:
		d_node.queue_free()
	dialogue_nodes.clear()
	temp_json_save_str = ''
	scene_name.text = 'Placeholder Scene Name'

func save() -> void:
	nodes_to_json()
	export_dialogue.current_file = scene_name.text + ".json"
	export_dialogue.popup_file_dialog()

func _on_popup_menu_id_pressed(id: int) -> void:
	if id == 0:
		print('add node clicked')
		toggle_unsaved_changes(true)
		var temp = dialogue_node.instantiate()
		var add_position : Vector2 = graph.get_local_mouse_position()
		
		temp.position_offset = (add_position + graph.scroll_offset) / graph.zoom
		temp.resizable = true
		temp.call_deferred("add_characters", character_portraits)
		temp.call_deferred("generate_uuid")
		temp.node_delete.connect(_on_node_deleted)
		temp.dragged.connect(_on_node_offset_changed)
		dialogue_nodes.append(temp)
		temp.call_deferred("set_node_number", (dialogue_nodes.size() - 1))
		graph.add_child(temp)


func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph.connect_node(from_node, from_port, to_node, to_port)
	toggle_unsaved_changes(true)

func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph.disconnect_node(from_node, from_port, to_node, to_port)
	toggle_unsaved_changes(true)


func _on_edit_scene_name_btn_pressed() -> void:
	sn_edit_popup.show()


func _on_close_scene_name_btn_pressed() -> void:
	sn_edit_popup.hide()
	sn_edit_box.clear()


func _on_accept_scene_name_btn_pressed() -> void:
	scene_name.text = sn_edit_box.text
	toggle_unsaved_changes(true)
	sn_edit_popup.hide()
	sn_edit_box.clear()

func _on_scene_name_edit_text_submitted(new_text: String) -> void:
	scene_name.text = sn_edit_box.text
	toggle_unsaved_changes(true)
	sn_edit_popup.hide()
	sn_edit_box.clear()


func _on_export_btn_pressed() -> void:
	nodes_to_json()
	export_dialogue.current_file = scene_name.text + ".json"
	export_dialogue.popup_file_dialog()


func _on_import_btn_pressed() -> void:
	if has_unsaved_changes:
		import_unsaved_changes.popup_centered_clamped()
	else:
		import_dialogue.popup()
	#json_to_nodes()

func _on_node_deleted(nn: int) -> void:
	dialogue_nodes.remove_at(nn)
	toggle_unsaved_changes(true)
	# need to reset node numbers of other nodes now
	var i : int = 0
	for d_node in dialogue_nodes:
		d_node.set_node_number(i)
		i += 1
	
	if dialogue_nodes.size() == 0 and (scene_name.text == '' or scene_name.text.is_empty() or scene_name.text =='Placeholder Scene Name'):
		print('blank scene, setting unsaved changes to no')
		toggle_unsaved_changes(false)

func toggle_unsaved_changes(desired_status: bool) -> void:
	if has_unsaved_changes and not desired_status:
		has_unsaved_changes = false
		unsaved_changes_ind.text = ''
	elif not has_unsaved_changes and desired_status:
		has_unsaved_changes = true
		unsaved_changes_ind.text = '(*)'

func _on_export_dialogue_file_selected(path: String) -> void:
	print(path)
	var save_file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	save_file.store_string(temp_json_save_str)
	save_file.close()
	toggle_unsaved_changes(false)


func _on_new_scene_btn_pressed() -> void:
	if has_unsaved_changes:
		unsaved_changes.popup_centered_clamped()
	else:
		clear_scene()
		sn_edit_popup.show()
		#clear_scene()

func _save_before_new_scene(action_name: String) -> void:
	if action_name == "save":
		save()
	else:
		print('incorrect action from UnsavedChanges Save button')


func _on_unsaved_changes_confirmed() -> void:
	print("don't save")
	clear_scene()
	toggle_unsaved_changes(false)
	sn_edit_popup.show()


func _on_edit_scene_name_popup_visibility_changed() -> void:
	sn_edit_box.grab_focus()


func _on_import_dialogue_file_selected(path: String) -> void:
	print('opening %s' % path)
	clear_scene()
	print(path)
	temp_json_save_str = FileAccess.get_file_as_string(path)
	json_to_nodes()

func _on_node_offset_changed(from: Vector2, to:Vector2) -> void:
	if from != to:
		print('unsaved changes due to node moved')
		has_unsaved_changes = true

func _save_changes_load(action_name: String) -> void:
	if action_name == 'save_and_load':
		save()
		import_unsaved_changes.hide()
	else:
		print('incorrect action from Import save before Import button')


func _on_import_unsaved_changes_confirmation_confirmed() -> void:
	clear_scene()
	import_dialogue.popup_centered_clamped()


func _on_test_connections_pressed() -> void:
	print(graph.connections)
	var node_from
	var node_to
	var i = 0
	for d_nodes in dialogue_nodes:
		d_nodes.get_slots()
		if i == 0:
			node_from = d_nodes.name
		else:
			node_to = d_nodes.name
		i += 1
	#graph.connect_node(node_from, 0, node_to, 0)

func do_something(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	print('something from node {0} from port {1} to node {2} to port {3}'.format([from_node, from_port, to_node, to_port]))
	graph.connect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	pass
	#TODO: allow adding node from empty connection drag
	#print('node added from drag')
	#toggle_unsaved_changes(true)
	#var temp = dialogue_node.instantiate()
	#
	#temp.position_offset = (release_position + graph.scroll_offset) / graph.zoom
	#temp.resizable = true
	#temp.call_deferred("add_characters", character_portraits)
	#
	#temp.node_setup_complete.connect(_on_node_setup_complete)
	#temp.node_delete.connect(_on_node_deleted)
	#temp.dragged.connect(_on_node_offset_changed)
	#dialogue_nodes.append(temp)
	#temp.call_deferred("set_node_number", (dialogue_nodes.size() - 1))
	#graph.add_child(temp)
	#print('attempting to connect nodes:')
	#print('from node {0} on port {1} to node {2} on port 0'.format([from_node, from_port, temp.name]))
	##graph.call_deferred("connect_node",from_node, from_port, temp.name, 0)
	#call_deferred("do_something", from_node, from_port, temp.name, 0)
	#temp.call_deferred("generate_uuid")

func _on_node_setup_complete() -> void:
	print('node setup completed')
	node_loaded_num += 1
	if node_loaded_num == dialogue_nodes.size() and is_loading_nodes:
		load_connections(connections_load_dict)
		is_loading_nodes = false
