extends Control
class_name EntityPage

@onready var _parent: DialogEditorRoot = get_parent()
@onready var entity_label: RichTextLabel = $EntityListLabel
@onready var name_input_control: Control = $NameInputControl
@onready var name_input_line: LineEdit = $NameInputControl/EntityIdEdit
@onready var confirm_button: Button = $NameInputControl/ConfirmButton

func load_entity_page():
	entity_label.text = ""
	if _parent.current_json != "":
		for item in _parent.current_json_data:
			entity_label.text += "[url]" + item + "[/url] \t\t"  

func _on_back_button_pressed():
	_parent.open_json_page()

func _on_create_entity_pressed():
	name_input_control.visible = true
	await confirm_button.pressed
	
	var text = name_input_line.text
	var already_exists: bool = false
	
	for item in _parent.current_json_data:
		if item == text:
			already_exists = true
	
	if !already_exists:
		_parent.current_entity = text
		_parent.current_json_data[text] = {
			
		}
		_parent.save_current_json()
	else:
		print("ID not valid, it already exists")
	
	name_input_line.text = ""
	name_input_control.visible = false
	
	load_entity_page()

func _on_entity_list_label_meta_clicked(meta):
	for item in _parent.current_json_data:
		if item == meta:
			_parent.current_entity = meta
	
	visible = false
	_parent.open_topic_overview()
