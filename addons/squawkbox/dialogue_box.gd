extends Control

signal reply_chosen(reply_number)
signal clicked

@onready var character_portrait : TextureRect = $VBoxContainer/HBoxContainer/CharacterPortrait
@onready var dialogue_box : RichTextLabel = $VBoxContainer/HBoxContainer/Dialogue
@onready var replies_scroll : ScrollContainer = $VBoxContainer/ScrollContainer
@onready var replies_vbox : VBoxContainer = $VBoxContainer/ScrollContainer/RepliesVBox

enum ReplyState {HIDDEN, SHOW, LOCKED, INVALID}

var replies_btn_list : Array[Button]
var has_replies : bool = false
var reply_condition_vars : Dictionary

func _ready() -> void:
	pass
	#StoredVariables.send_variables.connect(_on_vars_sent)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit()

#func _process(_delta: float) -> void:
	#if Input.is_action_pressed("ui_accept"):# and has_focus():
		#print('next dialogue from ui_accept')
		#clicked.emit()

func set_portrait_from_path(path: String) -> void:
	var portrait_texture : Texture2D = load(path)
	character_portrait.texture = portrait_texture

func set_dialogue_text(dialogue: String) -> void:
	dialogue_box.text = dialogue

func create_replies(replies: Dictionary, replies_conditions: Dictionary) -> void:
	#print('create replies:')
	#print(replies_conditions)
	# making a change to test file copy

	var iter : int = 0
	replies_btn_list.clear()
	if replies.keys().size() > 0:
		for keys in replies:
			if replies_conditions.has(keys):
				#print('has conditions')
				var condition_check : ReplyState = check_conditions(replies_conditions[keys])
				if condition_check == ReplyState.SHOW:
					var tmp_btn = Button.new()
					tmp_btn.text = replies[keys]['text']
					tmp_btn.flat = true
					tmp_btn.name = str(iter)
					#tmp_btn.is_hovered.connect()
					tmp_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
					tmp_btn.pressed.connect(_on_reply_pressed.bind(iter))
					tmp_btn.mouse_filter = MOUSE_FILTER_STOP
					replies_btn_list.append(tmp_btn)
					replies_vbox.add_child(tmp_btn)
				elif condition_check == ReplyState.HIDDEN:
					pass
					#print('reply was hidden')
				elif condition_check == ReplyState.LOCKED:
					#print('reply was locked')
					var tmp_btn = Button.new()
					tmp_btn.text = replies[keys]['text']
					tmp_btn.flat = true
					tmp_btn.name = str(iter)
					#tmp_btn.is_hovered.connect()
					tmp_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
					tmp_btn.pressed.connect(_on_reply_pressed.bind(iter))
					tmp_btn.mouse_filter = MOUSE_FILTER_STOP
					tmp_btn.disabled = true
					replies_btn_list.append(tmp_btn)
					replies_vbox.add_child(tmp_btn)
			else:
				var tmp_btn = Button.new()
				tmp_btn.text = replies[keys]['text']
				tmp_btn.flat = true
				tmp_btn.name = str(iter)
				#tmp_btn.is_hovered.connect()
				tmp_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
				tmp_btn.pressed.connect(_on_reply_pressed.bind(iter))
				tmp_btn.mouse_filter = MOUSE_FILTER_STOP
				replies_btn_list.append(tmp_btn)
				replies_vbox.add_child(tmp_btn)
			iter += 1
	
	if replies_vbox.get_child_count() > 0:
		has_replies = true
		self.disabled = true
		#print(replies_btn_list[0])
		replies_btn_list[0].grab_focus()
	else:
		has_replies = false
		self.disabled = false
		self.grab_focus()
		#grab_focus()

#TODO: this is getting called 2x on first dialogue load, why? (maybe deferred call issue)
func check_conditions(conditions_in: Dictionary) -> ReplyState:
	var first_key = conditions_in.keys()[0]
	var returned_state : ReplyState = ReplyState.INVALID
	#print('\ndebug for check_conditions')
	#print(conditions_in[first_key])
	#for condition in conditions_in[first_key]:
		#print('checking condition:')
		#print(conditions_in)
	var did_end : bool = false
	var left_value : String
	var right_value : String
	var compare_op : String
	var status_value : String
	var condition_met : bool = false
	var first_value : bool = true

	#print('left value before assignment')
	#print(conditions_in[first_key])
	#print('printing values.....')
	for token in conditions_in[first_key]:
		match conditions_in[first_key][token]['type']:
			'value':
				if first_value:
					#print('assigned left value')
					left_value = conditions_in[first_key][token]['value']
					first_value = false
				else:
					#print('assigned right value')
					right_value = conditions_in[first_key][token]['value']
			'compare':
				compare_op = conditions_in[first_key][token]['value']
			'op':
				if conditions_in[first_key][token]['value'] == 'END':
					did_end = true
			'status':
				status_value = conditions_in[first_key][token]['value']
			_:
				print("ERROR: unknown condition type")
	
	#print('reply condition vars:')
	reply_condition_vars = SquawkBoxManager.player_vars_dict
	#print(reply_condition_vars)
	#print('left value:')
	#print(left_value)
	if reply_condition_vars.has(left_value):
		condition_met = run_comparison(reply_condition_vars[left_value], compare_op, right_value)
		# match compare_op:
		# 	'==':
		# 		condition_met = reply_condition_vars[left_value] == int(right_value)
		# 	'IS':
		# 		condition_met = reply_condition_vars[left_value] == right_value
		# 		#print('IS condition: ', condition_met)
		# 	'>':
		# 		condition_met = reply_condition_vars[left_value] > int(right_value)
		# 	'<':
		# 		condition_met = reply_condition_vars[left_value] < int(right_value)
		# 	'>=':
		# 		condition_met = reply_condition_vars[left_value] >= int(right_value)
		# 	'=<':
		# 		condition_met = reply_condition_vars[left_value] <= int(right_value)
		# 	_:
		# 		print("ERROR: unknown comparison operator")
		# 		condition_met = false
	else:
		print('ERROR: variable not found in player_vars')
		
	match status_value:
		'SHOW':
			if condition_met:
				#print('-------show selected-------')
				returned_state = ReplyState.SHOW
		'HIDDEN':
			if condition_met:
				#print('-------hidden selected-------')
				returned_state = ReplyState.HIDDEN
			else:
				#print('-------shown not hidden selected-------')
				returned_state = ReplyState.SHOW
		'LOCKED':
			if condition_met:
				#print('-------lock selected-------')
				returned_state = ReplyState.LOCKED
			else:
				#print('-------shown not locked selected-------')
				returned_state = ReplyState.SHOW
		_:
			print("ERROR: unknown value type")
	if not did_end:
		print('ERROR: condition statement missing END')
	if returned_state == ReplyState.INVALID:
		print('ERROR: condition statement missing valid state')
	return returned_state

func run_comparison(left_value, comparator: String, right_value) -> bool:
	var condition_met : bool
	if reply_condition_vars.has(left_value):
		match comparator:
			'==':
				condition_met = reply_condition_vars[left_value] == int(right_value)
			'IS':
				condition_met = reply_condition_vars[left_value] == right_value
				#print('IS condition: ', condition_met)
			'>':
				condition_met = reply_condition_vars[left_value] > int(right_value)
			'<':
				condition_met = reply_condition_vars[left_value] < int(right_value)
			'>=':
				condition_met = reply_condition_vars[left_value] >= int(right_value)
			'=<':
				condition_met = reply_condition_vars[left_value] <= int(right_value)
			'OR':
				run_comparison(left_value, comparator, right_value)
			'AND':
				run_comparison(left_value, comparator, right_value)
			_:
				print("ERROR: unknown comparison operator")
				condition_met = false
	else:
		print('ERROR: variable not found in player_vars')
	return condition_met

func does_have_replies() -> bool:
	return has_replies

func remove_replies() -> void:
	for child in replies_vbox.get_children():
		replies_vbox.remove_child(child)
		child.queue_free()
		
	#print('replies removed')
	has_replies = false

func _on_reply_pressed(reply_num: int) -> void:
	#print('reply pressed from dialogue box')
	reply_chosen.emit(reply_num)

func _on_vars_sent(vars_in: Dictionary) -> void:
	pass
	# reply_condition_vars.clear()
	# reply_condition_vars = vars_in.duplicate(true)
	# print('\n*************')
	# print('reply conditions in dialogue box')
	# print(reply_condition_vars)
	# print('*************\n')

func convert_value() -> void:
	pass
