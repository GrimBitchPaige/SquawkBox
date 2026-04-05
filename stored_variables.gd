extends Node

signal send_variables(variables)

var requested_vars : Dictionary
var send_vars : Array[String]
var player_vars : Dictionary = {"player.hp": 5.5, "quest.goblin_camp": "incomplete", "player.mana": 20, "player.strength": 20}


func _ready() -> void:
	pass
	#SquawkBoxManager.request_data.connect(_on_request_data_sent)

func _on_request_data_sent(dict_in: Dictionary) -> void:
	requested_vars.clear()
	requested_vars = dict_in.duplicate(true)
	#print("Received data:", requested_vars)
	#send_variables_back()

func send_variables_back(dict_in: Dictionary) -> Dictionary:
	requested_vars.clear()
	requested_vars = dict_in.duplicate(true)
	send_vars.clear()
	for reply in requested_vars:
		for condition_element in requested_vars[reply]:
			if player_vars.has(requested_vars[reply][condition_element]):
				print('found the variable')
				#Received data:{ "0": { "condition_0": "player.hp", "condition_1": "quest.goblin_camp" }, "1": { "condition_0": "player.mana" } }
				send_vars.append(requested_vars[reply][condition_element])
	#print('send vars:')
	#print(send_vars)
	var out_dict : Dictionary
	for request in send_vars:
		out_dict[request] = player_vars[request]
	#send_variables.emit(out_dict)
	return out_dict