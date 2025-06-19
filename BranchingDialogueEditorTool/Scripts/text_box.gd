extends Control
class_name TextBox

var arr_pos: int = 0
@onready var text_edit_label: TextEdit = $TextInput
@onready var up_button: Button = $DragAndMove/DragButtonCont/MoveUp
@onready var down_button: Button = $DragAndMove/DragButtonCont/MoveDown
@onready var delete_button: Button = $DeleteButton
@onready var select_index: OptionButton = $DragAndMove/DragButtonCont/SelectIndex

func _ready():
	set_text("")

func set_text(text: String):
	text_edit_label.text = text
