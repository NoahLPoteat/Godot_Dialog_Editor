extends Control
class_name ChoiceBox

signal updated

@onready var arr_pos: int = 0
@onready var text_edit_label: TextEdit = $TextInput
@onready var up_button: Button = $DragAndMove/DragButtonCont/MoveUp
@onready var down_button: Button = $DragAndMove/DragButtonCont/MoveDown
@onready var delete_button: Button = $DeleteButton
@onready var dest_topic: OptionButton = $DestTopic
@onready var modifier_edit: LineEdit = $ModifierEdit
@onready var select_index: OptionButton = $DragAndMove/DragButtonCont/SelectIndex

@onready var dests_arr: Array = []

func _ready():
	set_text("")

func set_text(text: String):
	text_edit_label.text = text
	updated.emit()

func create_destinations(dests: Array):
	for item in dests:
		dest_topic.add_item(item)
		dests_arr.append(item)

func set_destination(dest: String):
	var i = 0
	for item in dests_arr:
		if item == dest:
			dest_topic.selected = i
		i += 1
	updated.emit()

func _on_dest_topic_item_selected(index):
	set_destination(dests_arr[index])

func set_modifier(mod: String):
	if mod == "":
		mod = "none"
	modifier_edit.text = mod
	updated.emit()

func _on_text_input_text_changed():
	updated.emit()

func _on_modifier_edit_text_changed(new_text):
	if new_text == "":
		modifier_edit.text = "none"
	updated.emit()
