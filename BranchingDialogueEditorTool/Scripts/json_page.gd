extends Control
class_name JSONEditorPage

@onready var json_label = $JsonListLabel
@onready var _parent: DialogEditorRoot = get_parent()
@onready var name_input_control: Control = $NameInputControl
@onready var name_input: LineEdit = $NameInputControl/JsonNameInput
@onready var confirm_input: Button = $NameInputControl/ConfirmInput
@onready var select_dir: Button = $SelectFolder
@onready var dir_popup: FileDialog = $FileDialog

func create_json():
	var path = _parent.json_folder_path
	name_input_control.visible = true
	
	await confirm_input.pressed
	for item in _parent.json_file_array:
		if item == name_input.text + ".json" or name_input.text == "":
			#make overwrite popup later
			print("json already exists, or no name input, please enter different name")
			return
	
	#sets up and strigifys an empty base dictionary for the jsonfile
	var temp_dict = {
		
	}
	var json_str = JSON.stringify(temp_dict, "\n\t")
	#uses WRITE to create a new json file if it doesnt already exist.
	var json_to_save = FileAccess.open(_parent.json_folder_path + name_input.text + ".json", FileAccess.WRITE)
	
	print(_parent.json_folder_path + name_input.text + ".json")
	
	#stores the empty dict, closes the file, and reloads the list
	json_to_save.store_line(json_str)
	json_to_save.close()
	name_input.text = ""
	name_input_control.visible = false
	reload_json_list()

func reload_json_list():
	var json_arr = _parent.load_json_dir()
	json_label.text = ""
	for item in json_arr:
		json_label.text += "[url]" + str(item) + "[/url] \t \t"

##uses the meta variant of the [url] text to open a json, and then progress
## to the entity creation page.
func _on_json_list_label_meta_clicked(meta):
	
	for item in _parent.json_file_array:
		if meta == item:
			_parent.current_json = meta
			
			_parent.load_json(meta)
	
	visible = false
	_parent.open_entity_page()

func load_json_page():
	reload_json_list()
	visible = true


func _on_select_folder_pressed():
	select_dir.visible = false
	dir_popup.visible = true

func _on_file_dialog_dir_selected(dir):
	dir_popup.visible = false
	select_dir.visible = true
	
	_parent.json_folder_path = dir + "/"
	_parent.open_json_page()

func _on_file_dialog_canceled():
	dir_popup.visible = false
	select_dir.visible = true
