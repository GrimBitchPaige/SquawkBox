@tool

extends Control

@onready var check_box : CheckBox = $HBoxContainer/CheckBox
@onready var character_name : Label = $HBoxContainer/CharacterName
@onready var character_portrait : TextureRect = $HBoxContainer/CharacterPortrait

var character_portrait_path : String

func is_checked() -> bool:
	return check_box.is_pressed()

func create_row(portrait_path: String, char_name: String) -> void:
	character_portrait_path = portrait_path
	var tmp_texture : Texture2D = load(character_portrait_path)
	character_portrait.texture = tmp_texture
	character_name.text = char_name

func get_character_info() -> Dictionary:
	return {character_name.text: character_portrait_path}
