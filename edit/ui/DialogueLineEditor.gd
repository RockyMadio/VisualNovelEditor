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
	$ItemRequired.text = data.get("ItemRequired", "")
	$ItemGive.text = data.get("ItemGive", "")
	$Event.text = data.get("Event", "")

	for field in get_children():
		if field is LineEdit or field is TextEdit:
			field.text_changed.connect(_on_any_field_changed)
	$DeleteButton.pressed.connect(_on_DeleteButton_pressed)

func _on_any_field_changed(new_text=""):
	entry_data["ID"] = $ID.text
	entry_data["Speaker"] = $Speaker.text
	entry_data["Text"] = $Text.text
	entry_data["Next"] = $Next.text
	entry_data["Choices"] = $Choices.text
	entry_data["Avatar"] = $Avatar.text
	entry_data["ItemRequired"] = $ItemRequired.text
	entry_data["ItemGive"] = $ItemGive.text
	entry_data["Event"] = $Event.text
	emit_signal("data_changed", entry_data, entry_data["ID"])

func _on_DeleteButton_pressed():
	emit_signal("delete_requested", entry_data["ID"])
