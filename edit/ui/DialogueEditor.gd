extends Control

# written in C:\Users\...\AppData\Roaming\Godot\app_userdata\VisualNovelEditor
const DIALOGUE_PATH := "user://dialogue.json"


@onready var entries_container = $H/V/V/ScrollContainer/V/Entries
@onready var load_button =$H/V/H/V2/LoadJSON
@onready var save_button =$H/V/H/V2/SaveJSON
@onready var add_button = $H/V/V/ScrollContainer/V/AddNewEntry

@onready var create_button = $H/V/H/V/CreateNewFile
@onready var open_existing_button = $H/V/H/V/OpenExistingFile

@onready var info_label = $H/V/H/Control/InfoLabel
@onready var json_preview = $H/JSONPreview

@onready var file_dialog_open = $FileDialogOpen
@onready var file_dialog_save = $FileDialogSave
var dialogue_data: Array = []
var current_dialogue_path: String = DIALOGUE_PATH

var last_open_dir: String = ""
var last_save_dir: String = ""


func _ready():
	load_button.visible = false
	save_button.visible = false
	
	add_button.visible = false   # hide add_button initially
	info_label.visible = true    # show info label initially
	
	load_button.pressed.connect(load_json)
	save_button.pressed.connect(save_json)
	add_button.pressed.connect(_on_AddNewEntry_pressed)
	

	create_button.pressed.connect(_on_create_new_file_pressed)
	open_existing_button.pressed.connect(_on_open_existing_file_pressed)

	file_dialog_open.file_selected.connect(_on_file_open_selected)
	file_dialog_open.filters = PackedStringArray(["*.json ; JSON Files"])
	file_dialog_open.mode = FileDialog.FILE_MODE_OPEN_FILE

	file_dialog_save.file_selected.connect(_on_file_save_selected)
	file_dialog_save.filters = PackedStringArray(["*.json ; JSON Files"])
	file_dialog_save.mode = FileDialog.FILE_MODE_SAVE_FILE
	

func _on_open_existing_file_pressed():
	if last_open_dir != "":
		file_dialog_open.current_dir = last_open_dir
	else:
		file_dialog_open.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).get_base_dir()
	file_dialog_open.popup_centered()

func _on_create_new_file_pressed():
	if last_save_dir != "":
		file_dialog_save.current_dir = last_save_dir
	else:
		file_dialog_save.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).get_base_dir()
	file_dialog_save.popup_centered()


func _on_file_open_selected(path: String):
	current_dialogue_path = path
	last_open_dir = path.get_base_dir()
	load_json()
	load_button.visible = true
	save_button.visible = true
	add_button.visible = true
	info_label.visible = false     # hide label when file loaded


func _on_file_save_selected(path: String):
	current_dialogue_path = path
	last_save_dir = path.get_base_dir()
	save_json()
	load_button.visible = true
	save_button.visible = true
	add_button.visible = true
	info_label.visible = false     # hide label when file created



func visualize_json():
	var key_order := [
		"ID", "Speaker", "Text", "Next", "Choices",
		"Avatar",  "Event"
	]
	var dialogue_dict := {}
	for entry in dialogue_data:
		if entry.has("ID"):
			var ordered_entry := {}
			for k in key_order:
				ordered_entry[k] = entry.get(k, "")
			dialogue_dict[entry["ID"]] = ordered_entry
	json_preview.text = ordered_dict_to_json(dialogue_dict, key_order)




func load_json():
	if FileAccess.file_exists(current_dialogue_path):
		var file = FileAccess.open(current_dialogue_path, FileAccess.READ)
		if file == null:
			push_error("Failed to open file for reading: " + DIALOGUE_PATH)
			return
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if typeof(result) == TYPE_DICTIONARY:
			dialogue_data = []
			for id in result.keys():
				dialogue_data.append(result[id])
			refresh_ui()
			visualize_json()
		else:
			push_error("Dialogue file is not a dictionary structure.")
	else:
		dialogue_data = []
		json_preview.text = "{}"


func save_json():
	var dialogue_dict := {}
	var key_order := [
		"ID", "Speaker", "Text", "Next", "Choices",
		"Avatar", "Event"
	]

	for entry in dialogue_data:
		if entry.has("ID"):
			var ordered_entry := {}
			for k in key_order:
				ordered_entry[k] = entry.get(k, "")
			dialogue_dict[entry["ID"]] = ordered_entry

	var json_text := ordered_dict_to_json(dialogue_dict, key_order)

	var file = FileAccess.open(current_dialogue_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: " + DIALOGUE_PATH)
		return
	file.store_string(json_text)
	file.close()

	visualize_json()




func ordered_dict_to_json(data: Dictionary, key_order: Array) -> String:
	var json_str := "{\n"
	var keys = data.keys()
	keys.sort_custom(func(a, b): return int(a.get_slice("_", -1)) < int(b.get_slice("_", -1)))
	for i in range(keys.size()):
		var id = keys[i]
		var entry = data[id]
		json_str += "\t\"" + id + "\": {\n"
		for j in range(key_order.size()):
			var key = key_order[j]
			var value = entry.get(key, "")
			json_str += "\t\t\"" + key + "\": " + JSON.stringify(value)

			json_str += ",\n" if j < key_order.size() - 1 else "\n"
		json_str += "\t}"
		json_str += ",\n" if i < keys.size() - 1 else "\n"
	json_str += "}"
	return json_str






func refresh_ui():
	for i in entries_container.get_children():
		i.queue_free()

	for line in dialogue_data:
		var line_editor = preload("res://ui/DialogueLineEditor.tscn").instantiate()
		line_editor.set_data(line)
		line_editor.data_changed.connect(_on_line_data_changed)
		line_editor.delete_requested.connect(_on_line_deleted)
		
		# 👇 Connect move up/down
		line_editor.move_up_requested.connect(_on_line_move_up)
		line_editor.move_down_requested.connect(_on_line_move_down)
		entries_container.add_child(line_editor)

func _on_line_move_up(id: String):
	for i in range(1, dialogue_data.size()):
		if dialogue_data[i]["ID"] == id:
			var temp = dialogue_data[i]
			dialogue_data[i] = dialogue_data[i - 1]
			dialogue_data[i - 1] = temp
			break
	refresh_ui()

func _on_line_move_down(id: String):
	for i in range(dialogue_data.size() - 1):
		if dialogue_data[i]["ID"] == id:
			var temp = dialogue_data[i]
			dialogue_data[i] = dialogue_data[i + 1]
			dialogue_data[i + 1] = temp
			break
	refresh_ui()


func _on_line_data_changed(updated_line: Dictionary, id: String):
	for i in range(dialogue_data.size()):
		if dialogue_data[i]["ID"] == id:
			dialogue_data[i] = updated_line
			break

func _on_line_deleted(id: String):
	dialogue_data = dialogue_data.filter(func(entry): return entry["ID"] != id)
	refresh_ui()




func _on_AddNewEntry_pressed():
	var index := dialogue_data.size() + 1
	#var new_id = "new_" + str(Time.get_ticks_msec())
	var new_id := "new_" + str(index)

	var new_entry = {
		"ID": new_id,
		"Speaker": "",
		"Text": "",
		"Next": "",
		"Choices": "",
		"Avatar": "",
		"Event": ""
	}
	dialogue_data.append(new_entry)
	refresh_ui()
