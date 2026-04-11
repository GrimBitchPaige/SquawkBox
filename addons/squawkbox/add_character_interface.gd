@tool

extends Control

signal character_saved(path: String, char_name: String)

@onready var file_diag : FileDialog = $FileDialog
@onready var portrait : TextureRect = $VBoxContainer/HBoxContainer/Portrait
@onready var name_text : LineEdit = $VBoxContainer/HBoxContainer/CharacterName
@onready var missing_field : AcceptDialog = $MissingFieldPopup

var portrait_path : String
var character_name : String

func _on_button_pressed() -> void:
	print('add char portrait clicked')
	file_diag.popup()


func _on_line_edit_text_submitted(new_text: String) -> void:
	character_name = new_text
	if character_name == '':
		character_name = name_text.text
	
	if character_name == '' and portrait_path != '':
		missing_field.dialog_text = 'Please add a character name'
		missing_field.popup()
	elif character_name != '' and portrait_path == '':
		missing_field.dialog_text = 'Please add a character portrait'
		missing_field.popup()
	elif character_name == '' and portrait_path == '':
		missing_field.dialog_text = "You don't seem to have entered any character information"
		missing_field.popup()
	else:
		character_saved.emit(portrait_path, character_name)
		portrait.texture = null
		name_text.text = ''
		portrait_path = ''
		character_name = ''
		visible = false


func _on_file_dialog_file_selected(path: String) -> void:
	var tmp_texture : Texture2D = load(path)
	portrait.texture = tmp_texture
	portrait_path = path


func _on_add_character_btn_pressed() -> void:
	if character_name == '':
		character_name = name_text.text
	
	if character_name == '' and portrait_path != '':
		missing_field.dialog_text = 'Please add a character name'
		missing_field.popup()
	elif character_name != '' and portrait_path == '':
		missing_field.dialog_text = 'Please add a character portrait'
		missing_field.popup()
	elif character_name == '' and portrait_path == '':
		missing_field.dialog_text = "You don't seem to have entered any character information"
		missing_field.popup()
	else:
		character_saved.emit(portrait_path, character_name)
		portrait.texture = null
		name_text.text = ''
		portrait_path = ''
		character_name = ''
		visible = false


func _on_character_name_text_changed(new_text: String) -> void:
	character_name = new_text

func _on_close_btn_pressed() -> void:
	portrait.texture = null
	name_text.text = ''
	visible = false
