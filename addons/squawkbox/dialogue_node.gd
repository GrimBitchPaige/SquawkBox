@tool

extends GraphNode

signal node_delete(node_number)

@onready var close_btn : TextureButton = $HBoxContainer/DeleteNodeBtn
@onready var character_list : OptionButton = $HBoxContainer/CharacterSelect
@onready var character_portrait : TextureRect = $HBoxContainer/CharacterPortrait

var reply_count : int = 0
var character_dict : Dictionary
var reply_btns : Array
var reply_vars_list : Array[Node]
var node_id : String
var node_number : int
var current_portrait

var reply_var_list_ui : PackedScene = preload("res://addons/squawkbox/reply_variables_list.tscn")


func _enter_tree() -> void:
	pass

func _on_delete_node_btn_pressed() -> void:
	node_delete.emit(node_number)
	queue_free()

func add_characters(characters: Dictionary) -> void:
	character_dict = characters
	for key in characters:
		character_list.add_item(key)
	var portrait_texture : Texture2D = load(character_dict[character_dict.keys()[0]])
	current_portrait = character_dict[character_dict.keys()[0]]
	character_portrait.texture = portrait_texture
	title = character_dict.keys()[0]

func _on_add_reply_option_btn_pressed() -> void:
	#region CreateReplySlot
	var added_slot_num : int = get_child_count(false)
	reply_count += 1
	var reply_del_btn : Button = Button.new()
	reply_del_btn.text = 'del'
	reply_del_btn.pressed.connect(_on_reply_del_btn_pressed.bind(reply_count - 1))
	var reply_vars_btn : Button = Button.new()
	reply_vars_btn.text = 'vars'
	reply_vars_btn.pressed.connect(_on_reply_vars_btn_pressed.bind(reply_count - 1))
	var reply_label : Label = Label.new()
	reply_label.text = 'Reply %d:' % reply_count
	var reply_text : TextEdit = TextEdit.new()
	reply_text.placeholder_text = 'Enter reply text here'
	reply_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reply_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reply_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	reply_text.scroll_fit_content_height = true
	var reply_hbox : HBoxContainer = HBoxContainer.new()
	reply_hbox.custom_minimum_size.y = 50.0
	reply_hbox.add_child(reply_del_btn)
	reply_hbox.add_child(reply_vars_btn)
	reply_hbox.add_child(reply_label)
	reply_hbox.add_child(reply_text)
	var tmp = reply_hbox
	reply_btns.append(tmp)
	var reply_vars_edit : Node = reply_var_list_ui.instantiate()
	reply_vars_edit.visible = false
	reply_vars_edit.call_deferred("set_label", 'Reply %d' % reply_count)
	reply_vars_list.append(reply_vars_edit)
	reply_hbox.add_child(reply_vars_edit)
	add_child(reply_hbox)
	set_slot(added_slot_num, false, 0, Color.ALICE_BLUE, true, 0, Color.ALICE_BLUE, null, null, true)
	#endregion
	

func _on_character_select_item_selected(index: int) -> void:
	title = character_list.get_item_text(index)
	var portrait_texture : Texture2D = load(character_dict[character_list.get_item_text(index)])
	current_portrait = character_dict[character_list.get_item_text(index)]
	character_portrait.texture = portrait_texture

func _on_reply_del_btn_pressed(btn_num: int) -> void:
	print('reply %d pressed' % btn_num)
	reply_btns[btn_num].queue_free()
	reply_btns.remove_at(btn_num)
	reply_count -= 1
	var reshuffle_count : int = 1
	for btn in reply_btns:
		btn.get_child(2).text = 'Reply %d:' % reshuffle_count
		reshuffle_count += 1

func _on_reply_vars_btn_pressed(btn_num: int) -> void:
	if reply_vars_list[btn_num].visible:
		reply_vars_list[btn_num].visible = false
	else:
		#reply_vars_list[btn_num].set_label('Reply %d' % btn_num)
		reply_vars_list[btn_num].visible = true

func generate_uuid() -> void:
	for i in range(0,20):
		node_id += str(randi_range(0,9))

func get_data_dict() -> Dictionary:
	var return_dict : Dictionary = {}
	var data_dict : Dictionary
	
	data_dict["Character"] = title
	data_dict["Portrait"] = current_portrait
	data_dict["PositionX"] = position_offset.x
	data_dict["PositionY"] = position_offset.y
	
	return_dict[node_id] = data_dict
	
	return return_dict
	

func load_node_data(input_data: Dictionary, id: String) -> void:
	title = input_data["Character"]
	var portrait_texture : Texture2D = load(input_data["Portrait"])
	current_portrait = input_data["Portrait"]
	character_portrait.texture = portrait_texture
	node_id = id
	position_offset = Vector2(input_data["PositionX"], input_data["PositionY"])

func get_node_number() -> int:
	return node_number
	
func set_node_number(nn: int) -> void:
	node_number = nn
