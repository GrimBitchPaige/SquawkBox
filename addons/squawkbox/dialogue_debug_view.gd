extends Control

@onready var vars_container : VBoxContainer = $PanelContainer/DebugVarsVBox

var player_variables : Dictionary
# example Received data:{ "0": { "condition_0": "player.hp", "condition_1": "quest.goblin_camp" }, "1": { "condition_0": "player.mana" } }
func _ready() -> void:
	pass
	#player_variables = SquawkBoxManager.player_vars_dict
	#StoredVariables.send_variables.connect(_on_vars_sent)

# func _on_vars_sent(vars_in: Dictionary) -> void:
# 	print('recieved vars_in in dialogue_debug')
# 	print(vars_in)
# 	for label_node in vars_container.get_children():
# 		vars_container.remove_child(label_node)
# 		label_node.queue_free()
# 	for sent_var in vars_in:
# 		var tmp_lbl : Label = Label.new()
# 		tmp_lbl.text = sent_var + ": " + str(vars_in[sent_var])
# 		vars_container.add_child(tmp_lbl)

func set_labels(conditions_for_reply: Dictionary) -> void:
	clear_labels()
	#print('conditions for reply:')
	#print(conditions_for_reply)
	player_variables = SquawkBoxManager.player_vars_dict
	for player_var in player_variables:
		#print('sent var')
		#print(player_var)
		var tmp_lbl : Label = Label.new()
		tmp_lbl.text = player_var + ": " + str(player_variables[player_var])
		vars_container.add_child(tmp_lbl)
	var condition_label : Label = Label.new()
	var tmp_str : String = 'Condition: '
	for key in conditions_for_reply:
		for condition in conditions_for_reply[key]:
			for token in conditions_for_reply[key][condition]:
				tmp_str += str(conditions_for_reply[key][condition][token]["value"]) + " "
	condition_label.text = tmp_str
	vars_container.add_child(condition_label)

func clear_labels() -> void:
	for label_node in vars_container.get_children():
		vars_container.remove_child(label_node)
		label_node.queue_free()
