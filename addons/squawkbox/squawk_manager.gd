extends  Node

#signal request_data(v_data_request)

var test_var = 0
var current_dialogue_str : String
var scene_dialogue_dict : Dictionary
var player_vars_dict : Dictionary
var root_path : String = 'res://'
var dialague_box : PackedScene = preload("res://addons/squawkbox/dialogue_box.tscn")
var debug_ui : PackedScene = preload("res://addons/squawkbox/dialogue_debug_view.tscn")
#var debug_ui_instance
var dialogue_box_instance
var dialogue_path : String = 'res://TestDialogue.json'
var dialogue_data
var current_dialogue_box
var current_debug_ui
var current_dialogue_node : String
var is_done : bool = false
var is_dialogue_open : bool = false

#func _unhandled_input(event: InputEvent) -> void:
	#if is_dialogue_open:
		#if event is InputEventMouseButton and not current_dialogue_box.does_have_replies():
			#if event.button_index == MOUSE_BUTTON_LEFT:
				#if is_done:
					#print('click from unhandled')
					#unload_scene()
				#else:
					#print('click from unhandled')
					#print('next dialogue')

func _on_clicked() -> void:
	if not current_dialogue_box.does_have_replies():
		if is_done:
			unload_scene()
		else:
			var tmp_node_id = has_connecting_dialogue(current_dialogue_node)
			if tmp_node_id != 'None':
				next_dialogue(scene_dialogue_dict['data'][tmp_node_id], tmp_node_id)
				current_dialogue_node = tmp_node_id

func unload_scene() -> void:
	#print('unloading scene')
	is_dialogue_open = false
	is_done = false
	get_tree().root.remove_child(current_debug_ui)
	get_tree().root.remove_child(current_dialogue_box)
	current_dialogue_box.queue_free()
	current_debug_ui.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func load_scene(scene_name_in: StringName, is_debug: bool = false) -> void:
	is_dialogue_open = true
	is_done = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#print(scene_name_in)
	var path = root_path + scene_name_in + '.json'
	current_dialogue_str = FileAccess.get_file_as_string(path)
	scene_dialogue_dict = JSON.parse_string(current_dialogue_str)
	var data_keys = scene_dialogue_dict['data'].keys()
	current_dialogue_box = dialague_box.instantiate()
	if is_debug:
		current_debug_ui = debug_ui.instantiate()
		current_debug_ui.visible = true
		current_debug_ui.call_deferred("set_labels",scene_dialogue_dict['conditions'][data_keys[0]])
		get_tree().root.add_child(current_debug_ui)
	current_dialogue_box.pressed.connect(_on_dbox_btn_pressed)
	current_dialogue_node = data_keys[0]
	get_tree().root.add_child(current_dialogue_box)
	current_dialogue_box.call_deferred("set_portrait_from_path", scene_dialogue_dict['data'][data_keys[0]]['Portrait'])
	current_dialogue_box.call_deferred("set_dialogue_text", scene_dialogue_dict['data'][data_keys[0]]['Dialogue'])
	#print('creating first dialogue for scene load')
	current_dialogue_box.call_deferred("create_replies", scene_dialogue_dict['data'][data_keys[0]]['ReplyOptions'], \
		scene_dialogue_dict['conditions'][data_keys[0]])
	current_dialogue_box.reply_chosen.connect(_on_reply_chosen)
	#current_dialogue_box.clicked.connect(_on_clicked)
	current_dialogue_box.grab_focus()
	send_data_request()
	#print('loading dialogue reply conditions:')
	#print(scene_dialogue_dict['conditions'])
	
func does_have_conditions(node_id_in: String) -> bool:
	return scene_dialogue_dict['conditions'].has(node_id_in)


func send_data_request() -> void:
	var data_request_send : Dictionary
	for reply in scene_dialogue_dict['conditions'][current_dialogue_node]:
		var inner_dict : Dictionary
		for condition in scene_dialogue_dict['conditions'][current_dialogue_node][reply]:
			var tmp_str : String
			for token in scene_dialogue_dict['conditions'][current_dialogue_node][reply][condition]:
				if scene_dialogue_dict['conditions'][current_dialogue_node][reply][condition][token]["type"] == 'value' \
				 and '.' in scene_dialogue_dict['conditions'][current_dialogue_node][reply][condition][token]["value"]:
					if tmp_str == '':
						tmp_str = scene_dialogue_dict['conditions'][current_dialogue_node][reply][condition][token]["value"]
					else:
						tmp_str = tmp_str + ',' + scene_dialogue_dict['conditions'][current_dialogue_node][reply][condition][token]["value"]
			inner_dict[condition] = tmp_str
		data_request_send[reply] = inner_dict
	#request_data.emit(data_request_send)
	player_vars_dict = StoredVariables.send_variables_back(data_request_send)

func next_dialogue(next_dialogue_dict: Dictionary, node_id: String) -> void:
	#print('changing to next dialogue')
	if does_have_conditions(node_id):
		send_data_request()
	current_dialogue_box.set_portrait_from_path(next_dialogue_dict['Portrait'])
	current_dialogue_box.set_dialogue_text(next_dialogue_dict['Dialogue'])
	current_dialogue_box.remove_replies()
	if does_have_conditions(node_id):
		current_debug_ui.set_labels(scene_dialogue_dict['conditions'][node_id])
	var tmp_conditions : Dictionary
	if scene_dialogue_dict['conditions'].has(node_id):
		tmp_conditions = scene_dialogue_dict['conditions'][node_id]
	else:
		tmp_conditions = {}
	current_dialogue_box.create_replies(next_dialogue_dict['ReplyOptions'], tmp_conditions)
	if has_connecting_dialogue(node_id) == 'None':
		is_done = true
	#else:
		#send_data_request()

func has_connecting_dialogue(node_id: String) -> String:
	for reply_connection in scene_dialogue_dict['connections']:
		if scene_dialogue_dict['connections'][reply_connection]['from_node'] == node_id:
			return scene_dialogue_dict['connections'][reply_connection]['to_node']
	
	return 'None'

func _on_reply_chosen(reply_num: int) -> void:
	var found_next_dialogue : bool = false
	#print('\nreply %d picked' % reply_num)
	for reply_connection in scene_dialogue_dict['connections']:
		if (scene_dialogue_dict['connections'][reply_connection]['from_node'] == current_dialogue_node and
			scene_dialogue_dict['connections'][reply_connection]['from_port'] - 1 == reply_num):
				var search_node : String = scene_dialogue_dict['connections'][reply_connection]['to_node']
				#print('search node: %s' % search_node)
				#print(scene_dialogue_dict['data'][search_node])
				#print('\n')
				current_dialogue_node = search_node
				next_dialogue(scene_dialogue_dict['data'][search_node], search_node)
				found_next_dialogue = true
				break

func _on_dbox_btn_pressed() -> void:
	#print('dialogue over button pressed')
	if not current_dialogue_box.does_have_replies():
		if is_done:
			unload_scene()
		else:
			var tmp_node_id = has_connecting_dialogue(current_dialogue_node)
			if tmp_node_id != 'None':
				next_dialogue(scene_dialogue_dict['data'][tmp_node_id], tmp_node_id)
				current_dialogue_node = tmp_node_id
