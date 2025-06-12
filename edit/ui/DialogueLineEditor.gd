extends HBoxContainer

signal data_changed(data: Dictionary, id: String)
signal delete_requested(id: String)

var entry_data: Dictionary

func set_data(data: Dictionary):
	entry_data = data.duplicate()
	$ID.text = data.get("ID", "")
	$Speaker.text = data.get("Speaker", "")
	$Text.text = data.get("Text", "")
	$Next.text = data.get("Next", "")
	$Choices.text = data.get("Choices", "")
	$Avatar.text = data.get("Avatar", "")

	$Event.text = data.get("Event", "")

	for field in get_children():
		if field is LineEdit or field is TextEdit:
			field.text_changed.connect(_on_any_field_changed)
	$DeleteButton.pressed.connect(_on_DeleteButton_pressed)

func clean_text(text: String) -> String:
	return text.replace("\n", "").strip_edges()

func _on_any_field_changed(new_text=""):


	entry_data["Choices"] = clean_text($Choices.text)
	entry_data["Event"] = clean_text($Event.text)

	# Other fields unchanged
	entry_data["ID"] = $ID.text
	entry_data["Speaker"] = $Speaker.text
	entry_data["Text"] = $Text.text
	entry_data["Next"] = $Next.text
	entry_data["Avatar"] = $Avatar.text

	emit_signal("data_changed", entry_data, entry_data["ID"])




func _on_DeleteButton_pressed():
	emit_signal("delete_requested", entry_data["ID"])
