extends  Node

var test_var = 0
var current_dialogue_str : String
var current_dialogue_dict : Dictionary
var root_path : String = 'res://'
var dialague_box : PackedScene = preload("res://addons/squawkbox/dialogue_box.tscn")
var current_dialogue_box
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
				next_dialogue(current_dialogue_dict['data'][tmp_node_id], tmp_node_id)
				current_dialogue_node = tmp_node_id

func unload_scene() -> void:
	print('unloading scene')
	is_dialogue_open = false
	is_done = false
	get_tree().root.remove_child(current_dialogue_box)
	current_dialogue_box.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func load_scene(scene_name_in: StringName) -> void:
	is_dialogue_open = true
	is_done = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print(scene_name_in)
	var path = root_path + scene_name_in + '.json'
	current_dialogue_str = FileAccess.get_file_as_string(path)
	current_dialogue_dict = JSON.parse_string(current_dialogue_str)
	current_dialogue_box = dialague_box.instantiate()
	current_dialogue_box.pressed.connect(_on_dbox_btn_pressed)
	var data_keys = current_dialogue_dict['data'].keys()
	current_dialogue_node = data_keys[0]
	get_tree().root.add_child(current_dialogue_box)
	current_dialogue_box.call_deferred("set_portrait_from_path", current_dialogue_dict['data'][data_keys[0]]['Portrait'])
	current_dialogue_box.call_deferred("set_dialogue_text", current_dialogue_dict['data'][data_keys[0]]['Dialogue'])
	current_dialogue_box.call_deferred("create_replies", current_dialogue_dict['data'][data_keys[0]]['ReplyOptions'])
	current_dialogue_box.reply_chosen.connect(_on_reply_chosen)
	#current_dialogue_box.clicked.connect(_on_clicked)
	current_dialogue_box.grab_focus()

func next_dialogue(next_dialogue_dict: Dictionary, node_id: String) -> void:
	print('changing to next dialogue')
	current_dialogue_box.set_portrait_from_path(next_dialogue_dict['Portrait'])
	current_dialogue_box.set_dialogue_text(next_dialogue_dict['Dialogue'])
	current_dialogue_box.remove_replies()
	current_dialogue_box.create_replies(next_dialogue_dict['ReplyOptions'])
	if has_connecting_dialogue(node_id) == 'None':
		is_done = true

func has_connecting_dialogue(node_id: String) -> String:
	for reply_connection in current_dialogue_dict['connections']:
		if current_dialogue_dict['connections'][reply_connection]['from_node'] == node_id:
			return current_dialogue_dict['connections'][reply_connection]['to_node']
	
	return 'None'

func _on_reply_chosen(reply_num: int) -> void:
	var found_next_dialogue : bool = false
	print('\nreply %d picked' % reply_num)
	for reply_connection in current_dialogue_dict['connections']:
		if (current_dialogue_dict['connections'][reply_connection]['from_node'] == current_dialogue_node and
			current_dialogue_dict['connections'][reply_connection]['from_port'] - 1 == reply_num):
				var search_node : String = current_dialogue_dict['connections'][reply_connection]['to_node']
				print('search node: %s' % search_node)
				print(current_dialogue_dict['data'][search_node])
				print('\n')
				current_dialogue_node = search_node
				next_dialogue(current_dialogue_dict['data'][search_node], search_node)
				found_next_dialogue = true
				break

func _on_dbox_btn_pressed() -> void:
	print('dialogue over button pressed')
	if not current_dialogue_box.does_have_replies():
		if is_done:
			unload_scene()
		else:
			var tmp_node_id = has_connecting_dialogue(current_dialogue_node)
			if tmp_node_id != 'None':
				next_dialogue(current_dialogue_dict['data'][tmp_node_id], tmp_node_id)
				current_dialogue_node = tmp_node_id
