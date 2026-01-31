@tool

extends GraphNode

@onready var close_btn : TextureButton = $HBoxContainer/DeleteNodeBtn
@onready var character_list : OptionButton = $HBoxContainer/CharacterSelect
@onready var character_portrait : TextureRect = $HBoxContainer/CharacterPortrait

var reply_count : int = 0
var character_dict : Dictionary
var reply_btns : Array

func _on_delete_node_btn_pressed() -> void:
	queue_free()

func add_characters(characters: Dictionary) -> void:
	character_dict = characters
	for key in characters:
		character_list.add_item(key)
	var portrait_texture : Texture2D = load(character_dict[character_dict.keys()[0]])
	character_portrait.texture = portrait_texture
	title = character_dict.keys()[0]

func _on_add_reply_option_btn_pressed() -> void:
	var added_slot_num : int = get_child_count(false)
	reply_count += 1
	var reply_del_btn : Button = Button.new()
	reply_del_btn.text = 'del'
	reply_del_btn.pressed.connect(_on_reply_del_btn_pressed.bind(reply_count - 1))
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
	reply_hbox.add_child(reply_label)
	reply_hbox.add_child(reply_text)
	var tmp = reply_hbox
	reply_btns.append(tmp)
	add_child(reply_hbox)
	set_slot(added_slot_num, false, 0, Color.ALICE_BLUE, true, 0, Color.ALICE_BLUE, null, null, true)
	

func _on_character_select_item_selected(index: int) -> void:
	title = character_list.get_item_text(index)
	var portrait_texture : Texture2D = load(character_dict[character_list.get_item_text(index)])
	character_portrait.texture = portrait_texture

func _on_reply_del_btn_pressed(btn_num: int) -> void:
	print('reply %d pressed' % btn_num)
	reply_btns[btn_num].queue_free()
	reply_btns.remove_at(btn_num)
	reply_count -= 1
	var reshuffle_count : int = 1
	for btn in reply_btns:
		btn.get_child(1).text = 'Reply %d:' % reshuffle_count
		reshuffle_count += 1
