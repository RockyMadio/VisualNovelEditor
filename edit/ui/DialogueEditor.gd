extends Control

# written in C:\Users\...\AppData\Roaming\Godot\app_userdata\VisualNovelEditor
const DIALOGUE_PATH := "user://dialogue.json"


@onready var entries_container = $HBoxContainer/VBoxContainer/ScrollContainer/Entries
@onready var load_button = $HBoxContainer/VBoxContainer/LoadJSON
@onready var save_button = $HBoxContainer/VBoxContainer/SaveJSON
@onready var add_button = $HBoxContainer/VBoxContainer/AddNewEntry

var dialogue_data: Array = []

func _ready():
	load_button.pressed.connect(load_json)
	save_button.pressed.connect(save_json)
	add_button.pressed.connect(_on_AddNewEntry_pressed)
	load_json()
	

func load_json():
	if FileAccess.file_exists(DIALOGUE_PATH):
		var file = FileAccess.open(DIALOGUE_PATH, FileAccess.READ)
		if file == null:
			push_error("Failed to open file for reading: " + DIALOGUE_PATH)
			return
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if !result.size():
			return
		dialogue_data = result
		refresh_ui()
	else:
		dialogue_data = []


func save_json():
	var json_text = JSON.stringify(dialogue_data, "\t")
	if json_text == null:
		push_error("Failed to stringify dialogue data!")
		return
	var file = FileAccess.open(DIALOGUE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: " + DIALOGUE_PATH)
		return
	file.store_string(json_text)
	file.close()


func refresh_ui():
	for i in entries_container.get_children():
		i.queue_free()

	for line in dialogue_data:
		var line_editor = preload("res://ui/DialogueLineEditor.tscn").instantiate()
		line_editor.set_data(line)
		line_editor.data_changed.connect(_on_line_data_changed)
		line_editor.delete_requested.connect(_on_line_deleted)
		entries_container.add_child(line_editor)

func _on_line_data_changed(updated_line: Dictionary, id: String):
	for i in range(dialogue_data.size()):
		if dialogue_data[i]["ID"] == id:
			dialogue_data[i] = updated_line
			break

func _on_line_deleted(id: String):
	dialogue_data = dialogue_data.filter(func(entry): return entry["ID"] != id)
	refresh_ui()

func _on_AddNewEntry_pressed():
	var new_id = "new_" + str(Time.get_ticks_msec())
	var new_entry = {
		"ID": new_id,
		"Speaker": "",
		"Text": "",
		"Next": "",
		"Choices": "",
		"Avatar": "",
		"ItemRequired": "",
		"ItemGive": "",
		"Event": ""
	}
	dialogue_data.append(new_entry)
	refresh_ui()
