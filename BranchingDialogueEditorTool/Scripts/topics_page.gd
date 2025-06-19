extends Control
class_name TopicsOverview

signal deletion_await

@onready var _parent: DialogEditorRoot = get_parent()
@onready var topic_name_input: LineEdit = $NameInputControl/TopicNameInput
@onready var confirm_button: Button = $NameInputControl/ConfirmButton
@onready var name_input_control: Control = $NameInputControl
@onready var topic_overview_label: RichTextLabel = $TopicsOverviewLabel

@onready var do_delete: bool = false
@onready var confirm_delete: Control = $Confirm

func _on_delete_entity_pressed():
	confirm_delete.visible = true
	await deletion_await
	if do_delete:
		var json = _parent.current_json_data
		json.erase(_parent.current_entity)
		_parent.open_entity_page()
		_parent.save_current_json()
	confirm_delete.visible = false

func _on_confirm_delete_pressed():
	do_delete = true
	deletion_await.emit()

func _on_cancel_delete_pressed():
	do_delete = false
	deletion_await.emit()

func load_topics_overview():
	_parent.topics_arr = []
	topic_overview_label.text = ""
	for item in _parent.current_json_data[_parent.current_entity]:
		_parent.topics_arr.append(item)
		topic_overview_label.text += "[url]" + item + "[/url] \t\t"

func _on_back_pressed():
	_parent.open_entity_page()

func _on_create_topic_pressed():
	name_input_control.visible = true
	await confirm_button.pressed
	
	var text = topic_name_input.text
	var already_exists: bool = false
	
	for item in _parent.current_json_data[_parent.current_entity]:
		if item == text:
			already_exists = true
	
	if !already_exists:
		_parent.current_topic = text
		var current_ent = _parent.current_json_data[_parent.current_entity]
		current_ent[text] = {
			"textNum" = 0,
			"choiceNum" = 0
		}
		_parent.save_current_json()
	else:
		print("topic already exists")
	
	topic_name_input.text = ""
	name_input_control.visible = false
	load_topics_overview()

func _on_topics_overview_label_meta_clicked(meta):
	for item in _parent.current_json_data[_parent.current_entity]:
		if item == meta:
			_parent.current_topic = meta
	
	visible = false
	_parent.open_topic_page()
