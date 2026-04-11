@tool

extends HBoxContainer

signal var_del(value_from_signal: int)

@onready var var_name_edit : LineEdit = $VariableName
@onready var result_type_select : OptionButton = $ResultOptions

var var_name : String
var result_type : String
var reply_var_num : int
var selected_result : int

func set_var_num(num_in: int) -> void:
	reply_var_num = num_in

func get_var_num() -> int:
	return reply_var_num


func _on_result_options_item_selected(index: int) -> void:
	selected_result = index
	
func get_var_info() -> Array[String]:
	return [var_name, result_type_select.get_item_text(selected_result)]

func _on_variable_name_text_submitted(new_text: String) -> void:
	var_name = new_text


func _on_delete_btn_pressed() -> void:
	var_del.emit(reply_var_num)


func _on_variable_name_text_changed(new_text: String) -> void:
	var_name = new_text
