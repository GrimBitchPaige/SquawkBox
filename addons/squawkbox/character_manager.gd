@tool
extends Control

signal editor_closed(send_chars_list)

#@onready var vbox : VBoxContainer = $VBoxContainer
@onready var add_character_dialogue : Node = $AddCharacterInterface
@onready var delete_confirm : ConfirmationDialog = $DeleteConfirmDiag
@onready var character_rows_scroll : VBoxContainer = $VBoxContainer/CharactersScrollContainer/CharacterVBox
@onready var load_char_lst : FileDialog = $LoadCharListDiag
@onready var save_char_lst : FileDialog = $SaveCharListDiag

var character_row : PackedScene = preload("res://addons/squawkbox/character_row.tscn")
var characters : Array
var changes_made : bool = false


func get_character_list() -> Dictionary:
	var tmp_dict : Dictionary
	print('chars from get_characters_list')
	if characters.size() > 0:
		var iter : int = 0
		for row in characters:
			var row_dict : Dictionary = row.get_character_info()
			tmp_dict[iter] = row_dict
			iter += 1
	return tmp_dict
	
func load_character_rows(in_dict: Dictionary) -> void:
	pass

func load_default_list() -> void:
	var open_file : FileAccess = FileAccess.open("res://Characters.json", FileAccess.READ)
	var tmp_str : String = open_file.get_as_text()
	var tmp_char_dict : Dictionary = JSON.parse_string(tmp_str)
	for character in tmp_char_dict:
		var tmp_row : Node = character_row.instantiate()
		var tmp_name : String = tmp_char_dict[character].keys()[0]
		var tmp_path : String = tmp_char_dict[character][tmp_name]
		tmp_row.call_deferred("create_row", tmp_path, tmp_name)
		characters.append(tmp_row)
		character_rows_scroll.add_child(tmp_row)
	print('loaded default character list from res://Characters.json')
	

func _ready() -> void:
	print('character manager ready function')
	add_character_dialogue.character_saved.connect(_on_character_saved)
	load_default_list()

func _on_add_character_btn_pressed() -> void:
	add_character_dialogue.visible = true

func _on_hide_btn_pressed() -> void:
	visible = false
	#editor_closed.emit(get_character_list())
	#print('hide character manager')

func _on_character_saved(path_to_portrait: String, added_char_name: String) -> void:
	print('character added')
	changes_made = true
	var tmp_row : Node = character_row.instantiate()
	tmp_row.call_deferred("create_row", path_to_portrait, added_char_name)
	characters.append(tmp_row)
	character_rows_scroll.add_child(tmp_row)

func _on_delete_character_btn_pressed() -> void:
	delete_confirm.popup()

func _on_delete_confirm_diag_confirmed() -> void:
	if characters.size() > 0:
		for row in characters:
			if row.is_checked():
				character_rows_scroll.remove_child(row)
				row.queue_free()
		changes_made = true


func _on_hidden() -> void:
	if changes_made:
		editor_closed.emit(get_character_list())
		changes_made = false
	else:
		print('character manager closed with no changes')


func _on_load_char_list_btn_pressed() -> void:
	load_char_lst.popup_centered()


func _on_load_char_list_diag_file_selected(path: String) -> void:
	print('load character list %s' % path)
	var open_file : FileAccess = FileAccess.open(path, FileAccess.READ)
	var tmp_str : String = open_file.get_as_text()
	var tmp_char_dict : Dictionary = JSON.parse_string(tmp_str)
	for character in tmp_char_dict:
		var tmp_row : Node = character_row.instantiate()
		var tmp_name : String = tmp_char_dict[character].keys()[0]
		var tmp_path : String = tmp_char_dict[character][tmp_name]
		tmp_row.call_deferred("create_row", tmp_path, tmp_name)
		characters.append(tmp_row)
		character_rows_scroll.add_child(tmp_row)
	changes_made = true


func _on_save_char_list_diag_file_selected(path: String) -> void:
	var save_str : String = JSON.stringify(get_character_list(), '\t', false)
	var save_file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	save_file.store_string(save_str)
	save_file.close()


func _on_save_char_list_btn_pressed() -> void:
	save_char_lst.current_file = 'Characters.json'
	save_char_lst.popup_centered()
