extends  Node

var test_var = 0
var current_dialogue_str : String
var current_dialogue_dict : Dictionary
var root_path : String = 'res://'
var dialague_box : PackedScene = preload("res://addons/squawkbox/dialogue_box.tscn")
var current_dialogue_box

func load_scene(scene_name_in: StringName) -> void:
	print(scene_name_in)
	var path = root_path + scene_name_in + '.json'
	current_dialogue_str = FileAccess.get_file_as_string(path)
	current_dialogue_dict = JSON.parse_string(current_dialogue_str)
	current_dialogue_box = dialague_box.instantiate()
	var data_keys = current_dialogue_dict['data'].keys()
	get_tree().root.add_child(current_dialogue_box)
	current_dialogue_box.call_deferred("set_portrait_from_path", current_dialogue_dict['data'][data_keys[0]]['Portrait'])
	current_dialogue_box.call_deferred("set_dialogue_text", current_dialogue_dict['data'][data_keys[0]]['Dialogue'])
	current_dialogue_box.call_deferred("create_replies", current_dialogue_dict['data'][data_keys[1]]['ReplyOptions'])
	
