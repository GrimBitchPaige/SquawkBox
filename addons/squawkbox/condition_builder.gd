@tool

extends Control

@onready var node_lbl : Label = $VBoxContainer/HBoxContainer2/NodeLbl
@onready var reply_lbl : Label = $VBoxContainer/HBoxContainer2/ReplyLbl
@onready var condition_holder : VBoxContainer = $VBoxContainer/HBoxContainer/ConditionHolderVBox

#region Too many buttons
@onready var equal_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/EqualBtn
@onready var less_than_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/LessThanBtn
@onready var greater_than_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/GreaterThanBtn
@onready var less_than_equal_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/LessThanEqualBtn
@onready var greater_than_equal_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/GreaterThanEqualBtn
@onready var value_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/ValueBtn
@onready var end_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/EndStatementBtn
@onready var or_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/OrBtn
@onready var and_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/AndBtn
@onready var left_closure_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/LeftClosureBtn
@onready var right_closure_op : Button = $VBoxContainer/HBoxContainer/ScrollContainer/ConditionTokensVBox/RightClosureBtn
#endregion

var ops_array : Array
var reply_conditions_dict : Dictionary
var default_node_lbl_txt : String = 'Node: {char name and node id}'
var default_reply_lbl_txt : String = 'Reply: {reply number}'
var node_id : String
var reply_number : int
var condition_statements : Array
var export_dict : Dictionary
var condition_count : int = 0

#TODO: probably change this to not be dumb later
var needs_new_flow_container : bool = true
var current_flow_container : int

func set_label_text(char_name: String, node_id_in: String, reply_number_in: int) -> void:
	var tmp_str : String = default_node_lbl_txt
	tmp_str = tmp_str.replace('{char name and node id}', char_name + node_id_in.substr(0, 6))
	node_lbl.text = tmp_str
	
	tmp_str = default_reply_lbl_txt
	tmp_str = tmp_str.replace('{reply number}', str(reply_number_in+1))
	reply_lbl.text = tmp_str
	
	node_id = node_id_in
	reply_number = reply_number_in

func export_conditions() -> Dictionary:
	var ops_dict : Dictionary
	var outer_dict : Dictionary
	var iter : int = 0
	var conditions_iter : int = 0
	export_dict.clear()
	export_dict['node_id'] = node_id
	export_dict['reply_num'] = reply_number
	for node in condition_statements:
		for child in node.get_child(0).get_children():
				if child is MarginContainer:
					for grandchild in child.get_children():
						if grandchild is HFlowContainer:
							for great_grandchild in grandchild.get_children():
								if great_grandchild is not TextureButton:
									var tmp_val : String = great_grandchild.text
									if great_grandchild is LineEdit:
										ops_dict['token_%d' % iter] = {'type': 'value','value': tmp_val}
									elif tmp_val == '<' or tmp_val == '>' or tmp_val == '<=' or tmp_val == '>=' or tmp_val == '==' or tmp_val == 'IS':
										ops_dict['token_%d' % iter] = {'type': 'compare','value': tmp_val}
									elif tmp_val == 'SHOW' or tmp_val == 'HIDDEN' or tmp_val == 'LOCKED':
										ops_dict['token_%d' % iter] = {'type': 'status','value': tmp_val}
									else:
										ops_dict['token_%d' % iter] = {'type': 'op','value': tmp_val}
									
									iter += 1
		outer_dict['condition_%d' % conditions_iter] = ops_dict.duplicate_deep(2)
		ops_dict.clear()
		conditions_iter += 1
		iter = 0
	export_dict.merge(outer_dict)
	return export_dict
	
func import_conditions(node_id_in: String, dict_in: Dictionary) -> void:
	if node_id_in != node_id:
		push_error("Error: condition node id passed to wrong node")
	else:
		print('imported conditions:')
		for condition in dict_in:
			for token in dict_in[condition]:
				if dict_in[condition][token]['type'] == 'op':
					add_op(dict_in[condition][token]['value'])
				elif dict_in[condition][token]['type'] == 'value':
					add_op('value', dict_in[condition][token]['value'])

func get_identifiers() -> Array:
	return [node_id, reply_number]
	
func add_op(op_in: String, value_in: String = '') -> void:
	var tmp_op
	if op_in != 'value':
		tmp_op = Label.new()
		tmp_op.custom_minimum_size = Vector2(15, 20)
		tmp_op.text = op_in
		ops_array.append(tmp_op)
	else:
		tmp_op = LineEdit.new()
		#tmp_op.custom_minimum_size = Vector2()
		tmp_op.expand_to_text_length = true
		if value_in != '':
			tmp_op.text = value_in
		ops_array.append(tmp_op)
	
	if needs_new_flow_container:
		var key_str : String = 'condition_%d' % condition_count
		print('added new flow container')
		current_flow_container = condition_statements.size()
		# Node structure reference because this is fucking confusing in code
		#PanelContainer
		#--HBoxContainer
		#----MarginContainer
		#------HFlowContainer
		#--------ops added here
		#----TextureButton
		var new_panel_container : PanelContainer = PanelContainer.new()
		new_panel_container.theme = load("res://addons/squawkbox/condition_statement_theme.tres")
		new_panel_container.size_flags_horizontal = Control.SIZE_FILL
		new_panel_container.custom_minimum_size.y = 20
		
		var new_hbox_container : HBoxContainer = HBoxContainer.new()
		#new_hbox_container.size_flags_horizontal = Control.SIZE_FILL
		
		var new_margin_container : MarginContainer = MarginContainer.new()
		new_margin_container.add_theme_constant_override("margin_left", 2)
		new_margin_container.add_theme_constant_override("margin_right", 2)
		new_margin_container.add_theme_constant_override("margin_top", 2)
		new_margin_container.add_theme_constant_override("margin_bottom", 2)
		new_margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var new_flow_container : HFlowContainer = HFlowContainer.new()
		new_flow_container.size_flags_horizontal = Control.SIZE_FILL
		new_flow_container.name = 'flow_container'
		
		var delete_btn : TextureButton = TextureButton.new()
		delete_btn.ignore_texture_size = true
		delete_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		delete_btn.texture_normal = load("res://addons/squawkbox/delete.png")
		delete_btn.custom_minimum_size.x = 30
		delete_btn.custom_minimum_size.y = 30
		delete_btn.pressed.connect(_on_condition_statement_delete_pressed.bind(current_flow_container))

		new_flow_container.add_child(tmp_op)
		new_margin_container.add_child(new_flow_container)
		new_hbox_container.add_child(new_margin_container)
		new_hbox_container.add_child(delete_btn)
		new_panel_container.add_child(new_hbox_container)
		condition_statements.append(new_panel_container)
		condition_holder.add_child(new_panel_container)
		needs_new_flow_container = false
	else:
		for child in condition_statements[current_flow_container].get_child(0).get_children():
			if child is MarginContainer:
				for grandchild in child.get_children():
					if grandchild is HFlowContainer:
						grandchild.add_child(tmp_op)
	
	if op_in == 'END':
		needs_new_flow_container = true
		condition_count += 1

func _on_equal_btn_pressed() -> void:
	add_op('==')

func _on_less_than_btn_pressed() -> void:
	add_op('<')

func _on_greater_than_btn_pressed() -> void:
	add_op('>')

func _on_less_than_equal_btn_pressed() -> void:
	add_op('<=')

func _on_greater_than_equal_btn_pressed() -> void:
	add_op('>=')

func _on_value_btn_pressed() -> void:
	add_op('value')

func _on_end_statement_btn_pressed() -> void:
	add_op('END')
	print('END op pressed')

func _on_or_btn_pressed() -> void:
	add_op('OR')

func _on_and_btn_pressed() -> void:
	add_op('AND')

func _on_close_btn_pressed() -> void:
	visible = false
	print(export_conditions())

func _on_then_btn_pressed() -> void:
	add_op('THEN')

func _on_show_btn_pressed() -> void:
	add_op('SHOW')

func _on_hidden_btn_pressed() -> void:
	add_op('HIDDEN')

func _on_locked_btn_pressed() -> void:
	add_op('LOCKED')

func _on_condition_statement_delete_pressed(statement_number: int) -> void:
	print('removing %d condition statement' % statement_number)
	#print(export_dict["condition_" + str(statement_number)])
	# { "node_id": "71037179315110714793", "reply_num": 0, "condition_0": { "token_0": { "type": "value", "value": "player" }, "token_1": { "type": "op", "value": "END" } } }
	print(condition_statements[statement_number])
	condition_holder.remove_child(condition_statements[statement_number])
	condition_statements[statement_number].queue_free()
	condition_statements.remove_at(statement_number)

	var conditions_iter : int = 0
	for condition in condition_statements:
		print('checking conditions after removal of %d' % statement_number)
		for child in condition.get_child(0).get_children():
			if child is TextureButton:
				print('rebinding condition delete with correct number')
				child.pressed.disconnect(_on_condition_statement_delete_pressed)
				child.pressed.connect(_on_condition_statement_delete_pressed.bind(conditions_iter))
		conditions_iter += 1

func _on_is_btn_pressed() -> void:
	add_op('IS')


func _on_left_closure_btn_pressed() -> void:
	add_op('(')


func _on_right_closure_btn_pressed() -> void:
	add_op(')')
