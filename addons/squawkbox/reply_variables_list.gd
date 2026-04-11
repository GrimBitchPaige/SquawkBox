@tool

extends Control

@onready var reply_lbl : Label = $VBoxContainer/HBoxContainer/ReplyNumLbl
@onready var add_variable : TextureButton = $VBoxContainer/HBoxContainer/AddVariableBtn
@onready var v_box : VBoxContainer = $VBoxContainer

var reply_number : int
var reply_var_tscn : PackedScene = preload("res://addons/squawkbox/reply_variable.tscn")
var reply_vars_list : Array

func set_label(text: String) -> void:
	reply_lbl.text = 'variable list for %s' % text


func _on_add_variable_btn_pressed() -> void:
	var tmp_rvar : Node = reply_var_tscn.instantiate()
	#tmp_rvar.call_deferred("set_var_num",reply_vars_list.size() + 1)
	tmp_rvar.set_var_num(reply_vars_list.size())
	tmp_rvar.var_del.connect(_on_reply_var_del_btn_pressed)
	reply_vars_list.append(tmp_rvar)
	v_box.add_child(tmp_rvar)

func _on_reply_var_del_btn_pressed(var_num: int) -> void:
	print('delete reply var number %d' % var_num)
	v_box.remove_child(reply_vars_list[var_num])
	reply_vars_list[var_num].queue_free()
	reply_vars_list.remove_at(var_num)
	
	var iter : int = 0
	for vars in reply_vars_list:
		vars.set_var_num(iter)
		iter += 1
