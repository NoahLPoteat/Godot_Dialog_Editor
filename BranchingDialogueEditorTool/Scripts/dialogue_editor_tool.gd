extends Control
class_name DialogEditorRoot

@export var json_folder_path: String = "D:/GitHub/Godot/Godot-PROTOTYPES/dialogue-system-prototype/Scenes/BranchingDialogueEditorTool/JsonFolder/"
@onready var json_file_array: Array

#the 4 pages used in the tool
@onready var json_page: JSONEditorPage = $JsonPage
@onready var entity_page: EntityPage = $EntityPage
@onready var topics_overview: TopicsOverview = $TopicsOverview 
@onready var topic_page: TopicPage = $IndividualTopicPage  

#these will be used to navigate and determine which json, entity, and topic
# the user is working in.
var current_json: String = ""
var current_json_data
var current_entity: String = ""
var current_topic: String = ""
var topics_arr: Array = []
var topic_text_arr: Array = []
var choices_arr: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().physics_frame
	var exe_path = OS.get_executable_path().get_base_dir() + "/"
	var dir = DirAccess.open(exe_path)
	var json_dir = "json_storage"
	var exists = false
	if dir:
		for file in DirAccess.get_directories_at(exe_path):
			if file == json_dir:
				exists = true
	
	if exists:
		json_folder_path = exe_path + json_dir + "/"
	else:
		dir.make_dir_recursive(exe_path + json_dir)
		json_folder_path = exe_path + json_dir + "/"
	
	open_json_page()


func load_json_dir():
	var dir = DirAccess.open(json_folder_path)
	var out_arr: Array = []
	if dir:
		for file in DirAccess.get_files_at(json_folder_path):
			if file.get_extension() == "json":
				out_arr.append(file)
	json_file_array = out_arr
	return out_arr


func load_json(meta):
	var file = FileAccess.open(json_folder_path + meta, FileAccess.READ)
	var json_obj = JSON.new()
	var parse_err = json_obj.parse(file.get_as_text())
	if parse_err == OK:
		current_json_data = json_obj.data
	else:
		json_obj.get_error_message()
		return

func open_json_page():
	json_page.load_json_page()
	json_page.visible = true
	entity_page.visible = false
	topics_overview.visible = false
	topic_page.visible = false

func open_entity_page():
	entity_page.load_entity_page()
	json_page.visible = false
	entity_page.visible = true
	topics_overview.visible = false
	topic_page.visible = false

func open_topic_overview():
	topics_overview.load_topics_overview()
	json_page.visible = false
	entity_page.visible = false
	topics_overview.visible = true
	topic_page.visible = false

func open_topic_page():
	topic_page.load_topic_page()
	json_page.visible = false
	entity_page.visible = false
	topics_overview.visible = false
	topic_page.visible = true

func save_current_json():
	var file = FileAccess.open(json_folder_path + current_json, FileAccess.WRITE)
	
	if file != null:
		var data_to_write = JSON.stringify(current_json_data, "\t")
		file.store_string(data_to_write)
		file.close()
		return true #returns true when the save is successful
	else:
		print("file opening error")
		return false
