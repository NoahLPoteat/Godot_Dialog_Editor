extends Control
class_name TopicPage

signal deletion_await

@onready var _parent: DialogEditorRoot = get_parent()
@onready var back_button: Button = $Back
#not needed as we will save on back but there as a precaution
@onready var save_button: Button = $SaveButton 

@onready var text_box = load("res://Scenes/BranchingDialogueEditorTool/text_box.tscn")
@onready var choice_box = load("res://Scenes/BranchingDialogueEditorTool/choice_box.tscn")

@onready var text_box_container: VBoxContainer = $TabContainer/TextMenu/TextBoxScrolling/TextboxContainer
@onready var choice_container: VBoxContainer = $TabContainer/ChoicesMenu/ChoiceScrolling/ChoiceContainer
@onready var confirm_box: Control = $Confirm

@onready var do_delete: bool = false

func _on_back_pressed():
	_parent.open_topic_overview()

func _on_save_button_pressed():
	_parent.save_current_json()

func _on_delete_topic_pressed():
	confirm_box.visible = true
	await deletion_await
	if do_delete:
		var entity = _parent.current_json_data[_parent.current_entity]
		entity.erase(_parent.current_topic)
		_parent.open_topic_overview()
		_parent.save_current_json()
	confirm_box.visible = false

func _on_confirm_delete_pressed():
	do_delete = true
	deletion_await.emit()

func _on_cancel_delete_pressed():
	do_delete = false
	deletion_await.emit()

func load_topic_page():
	_parent.topic_text_arr = []
	_parent.choices_arr = []
	do_delete = false
	
	for child in text_box_container.get_children():
		child.queue_free()
	for child in choice_container.get_children():
		child.queue_free()
	
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic = topics_dict[_parent.current_topic]
	
	for i in range(current_topic["textNum"]):
		_parent.topic_text_arr.append(current_topic["text" + str(i)])
	
	for i in range(current_topic["choiceNum"]):
		_parent.choices_arr.append(current_topic["choice" + str(i)])
	
	var i = 0
	for item in _parent.topic_text_arr: #initializes, and creates text boxes for each text
		create_text_box(i, item)
		i += 1
	
	i = 0
	for item in _parent.choices_arr:
		create_choice_box(i, item[0], item[1], item[2])
		i += 1

##########################################################################
## THE NEXT FEW FUNCTIONS HANDLE THE CREATION AND CONTROL OF TEXT BOXES ##
##########################################################################

#moves the text box left in the array, but up on the visual.
func text_box_up(arr_pos: int, text_box: TextBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	
	if !arr_pos - 1 < 0 :
		var text_cur_pos = current_topic["text" + str(arr_pos)] 
		var text_new_pos = current_topic["text" + str(arr_pos - 1)] 
		
		current_topic.erase("text" + str(arr_pos))
		current_topic.erase("text" + str(arr_pos - 1))
		
		current_topic["text" + str(arr_pos - 1)] = text_cur_pos
		current_topic["text" + str(arr_pos)] = text_new_pos
		
		load_topic_page()

#moves the text box right in the array, but down on the visual.
func text_box_down(arr_pos: int, text_box: TextBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	
	if arr_pos + 1 < current_topic["textNum"]:
		var text_cur_pos = current_topic["text" + str(arr_pos)] 
		var text_new_pos = current_topic["text" + str(arr_pos + 1)] 
		
		current_topic.erase("text" + str(arr_pos))
		current_topic.erase("text" + str(arr_pos + 1))
		
		current_topic["text" + str(arr_pos + 1)] = text_cur_pos
		current_topic["text" + str(arr_pos)] = text_new_pos
		
		load_topic_page()

func delete_text_box(arr_pos, text_box: TextBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	var found: bool = false
	
	for i in int(current_topic["textNum"]): #iterates i to the number of text boxes
		if i == arr_pos and !found: #becomes true when we find the text box we're working with
			found = true
		if found and i + 1 < current_topic["textNum"]:
			var text_cur_pos = current_topic["text" + str(i)] 
			var text_new_pos = current_topic["text" + str(i + 1)] 
			current_topic.erase("text" + str(i))
			current_topic.erase("text" + str(i + 1))
			current_topic["text" + str(i + 1)] = text_cur_pos
			current_topic["text" + str(i)] = text_new_pos
	
	current_topic.erase("text" + str(int(current_topic["textNum"]) - 1))
	current_topic["textNum"] -= 1
	load_topic_page()

func _on_add_text_box_button_pressed():
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	
	current_topic["text" + str(len(_parent.topic_text_arr))] = ""
	create_text_box(len(_parent.topic_text_arr), current_topic["text" + str(len(_parent.topic_text_arr))])
	current_topic["textNum"] += 1
	load_topic_page()

func create_text_box(pos: int, text: String):
	var new_text_box: TextBox = text_box.instantiate()
	text_box_container.add_child(new_text_box)
	
	for i in range(len(_parent.topic_text_arr)):
		new_text_box.select_index.add_item(str(i))
	new_text_box.arr_pos = pos
	new_text_box.set_text(text)
	new_text_box.select_index.selected = pos
	
	#connecting signals to their respective functions
	new_text_box.up_button.pressed.connect(text_box_up.bind(new_text_box.arr_pos, new_text_box))
	new_text_box.down_button.pressed.connect(text_box_down.bind(new_text_box.arr_pos, new_text_box))
	new_text_box.delete_button.pressed.connect(delete_text_box.bind(new_text_box.arr_pos, new_text_box))
	new_text_box.text_edit_label.text_changed.connect(text_box_text_changed.bind(new_text_box.arr_pos, new_text_box))
	new_text_box.select_index.item_selected.connect(change_text_index.bind(new_text_box.arr_pos, new_text_box))

func text_box_text_changed(arr_pos: int, text_box: TextBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	current_topic["text" + str(arr_pos)] = text_box.text_edit_label.text

func change_text_index(new_pos: int, arr_pos: int, text_box: TextBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	
	var text_to_move = current_topic["text" + str(arr_pos)]
	current_topic.erase(current_topic["text" + str(arr_pos)])
	
	if arr_pos < new_pos:
		for i in range(arr_pos + 1, new_pos + 1):
			var text_cur_pos = current_topic["text" + str(i)] 
			var text_new_pos = current_topic["text" + str(i - 1)] 
			current_topic.erase("text" + str(i))
			current_topic.erase("text" + str(i - 1))
			current_topic["text" + str(i - 1)] = text_cur_pos
			current_topic["text" + str(i)] = text_new_pos
	else:
		var text_pos_arr = []
		for i in range(new_pos, arr_pos):
			text_pos_arr.append(current_topic["text" + str(i)])
			current_topic.erase("text" + str(i))
		var x = 0
		for i in range(new_pos, arr_pos):
			current_topic["text" + str(i + 1)] = text_pos_arr[x]
			x += 1
	current_topic["text" + str(new_pos)] = text_to_move
	
	load_topic_page()

############################################################################
## THE NEXT FEW FUNCTIONS HANDLE THE CREATION AND CONTROL OF CHOICE BOXES ##
############################################################################

func create_choice_box(pos: int, text: String, dest: String, modifier: String):
	var new_choice_box: ChoiceBox = choice_box.instantiate()
	choice_container.add_child(new_choice_box)
	
	new_choice_box.arr_pos = pos
	new_choice_box.set_text(text)
	new_choice_box.create_destinations(_parent.topics_arr)
	new_choice_box.set_destination(dest)
	new_choice_box.set_modifier(modifier)
	for i in range(len(_parent.choices_arr)):
		new_choice_box.select_index.add_item(str(i))
	new_choice_box.select_index.selected = pos
	
	new_choice_box.up_button.pressed.connect(choice_box_up.bind(new_choice_box.arr_pos, new_choice_box))
	new_choice_box.down_button.pressed.connect(choice_box_down.bind(new_choice_box.arr_pos, new_choice_box))
	new_choice_box.delete_button.pressed.connect(delete_choice_box.bind(new_choice_box.arr_pos, new_choice_box))
	new_choice_box.updated.connect(choice_param_updated.bind(new_choice_box.arr_pos, new_choice_box))
	new_choice_box.select_index.item_selected.connect(change_choice_index.bind(new_choice_box.arr_pos, new_choice_box))

func choice_box_up(arr_pos: int, choice_box: ChoiceBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	
	if !arr_pos - 1 < 0:
		var choice_current_pos = current_topic["choice" + str(arr_pos)]
		var choice_new_pos = current_topic["choice" + str(arr_pos - 1)]
		
		current_topic.erase("choice" + str(arr_pos))
		current_topic.erase("choice" + str(arr_pos - 1))
		
		current_topic["choice" + str(arr_pos - 1)] = choice_current_pos
		current_topic["choice" + str(arr_pos)] = choice_new_pos
		
		load_topic_page()
 

func choice_box_down(arr_pos: int, choice_box: ChoiceBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	
	if arr_pos + 1 < current_topic["choiceNum"]:
		var choice_current_pos = current_topic["choice" + str(arr_pos)]
		var choice_new_pos = current_topic["choice" + str(arr_pos + 1)]
		
		current_topic.erase("choice" + str(arr_pos))
		current_topic.erase("choice" + str(arr_pos + 1))
		
		current_topic["choice" + str(arr_pos + 1)] = choice_current_pos
		current_topic["choice" + str(arr_pos)] = choice_new_pos
		
		load_topic_page()

func delete_choice_box(arr_pos: int, choice_box: ChoiceBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	var found: bool = false
	
	for i in int(current_topic["choiceNum"]):
		if i == arr_pos and !found:
			found = true
		if found and i + 1 < current_topic["choiceNum"]:
			var choice_current_pos = current_topic["choice" + str(i)]
			var choice_new_pos = current_topic["choice" + str(i + 1)]
			current_topic.erase("choice" + str(i))
			current_topic.erase("choice" + str(i + 1))
			current_topic["choice" + str(i + 1)] = choice_current_pos
			current_topic["choice" + str(i)] = choice_new_pos
	
	current_topic.erase("choice" + str(int(current_topic["choiceNum"]) - 1))
	current_topic["choiceNum"] -= 1
	load_topic_page()

func _on_add_choice_button_pressed():
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	
	var pos = len(_parent.choices_arr)
	current_topic["choice" + str(pos)] = ["", "", "none"]
	var arr = current_topic["choice" + str(pos)]
	
	create_choice_box(pos, arr[0], arr[1], arr[2])
	current_topic["choiceNum"] += 1
	load_topic_page()

func choice_param_updated(arr_pos: int, choice_box: ChoiceBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	
	current_topic["choice" + str(arr_pos)] = [
		choice_box.text_edit_label.text,
		_parent.topics_arr[choice_box.dest_topic.selected],
		choice_box.modifier_edit.text
		]

func change_choice_index(new_pos: int, arr_pos: int, choice_box: ChoiceBox):
	var topics_dict = _parent.current_json_data[_parent.current_entity]
	var current_topic: Dictionary = topics_dict[_parent.current_topic]
	
	
	var choice_to_move = current_topic["choice" + str(arr_pos)]
	current_topic.erase(current_topic["choice" + str(arr_pos)])
	
	if arr_pos < new_pos:
		for i in range(arr_pos + 1, new_pos + 1):
			var choice_current_pos = current_topic["choice" + str(i)]
			var choice_new_pos = current_topic["choice" + str(i - 1)]
			current_topic.erase("choice" + str(i))
			current_topic.erase("choice" + str(i - 1))
			current_topic["choice" + str(i - 1)] = choice_current_pos
			current_topic["choice" + str(i)] = choice_new_pos
	else:
		var choice_pos_arr = []
		for i in range(new_pos, arr_pos):
			choice_pos_arr.append(current_topic["choice" + str(i)])
			current_topic.erase("choice" + str(i))
		var x = 0
		for i in range(new_pos, arr_pos):
			current_topic["choice" + str(i + 1)] = choice_pos_arr[x]
			x += 1
	current_topic["choice" + str(new_pos)] = choice_to_move
	load_topic_page()
