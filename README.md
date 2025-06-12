# VisualNovelEditor
Easily build visual novel JSON files.

Godot-based tool to create and manage dialogue data in JSON format.

---

Features

* Add, edit, delete dialogue entries
* Save/load from `user://dialogue.json`
* JSON saved as a  **dictionary** , not an array
* Live preview of JSON in a `RichTextLabel`

## Project Structure

```
/main/DialogueEditor.tscn      - Main editor
/ui/DialogueLineEditor.tscn    - Per-entry UI
dialogue.json                  - Auto-generated
```

---

## Usage

* Open `DialogueEditor.tscn` in Godot and run it
* Use the buttons to add, edit, save, and load entries
* Fields: ID, Speaker, Text, Next, Choices, Avatar, ItemRequired, ItemGive, Event

---

## JSON Format

```json
{
  "intro_001": {
    "ID": "intro_001",
    "Speaker": "",
    "Text": "",
    ...
  }
}
```

* Saved as dictionary, sorted by ID suffix
* Keys follow consistent order

---

## Notes

* File saved to `%APPDATA%/Godot/app_userdata/YourProject/dialogue.json`
* Do not edit JSON manually unless needed


| Field                  | What to write / example                                                                                         |
| ---------------------- | --------------------------------------------------------------------------------------------------------------- |
| **ID**           | Unique identifier for this dialogue line, e.g.`"line_001"`                                                    |
| **Speaker**      | Name of the character speaking, e.g.`"Alice"`                                                                 |
| **Text**         | The actual dialogue text shown to the player                                                                    |
| **Next**         | The ID of the next line to go to if there’s no branching, e.g.`"line_002"`or leave empty if end              |
| **Choices**      | Branching options, format:`Label1:ID1,Label2:ID2`e.g.`Yes:line_003,No:line_004`                             |
| **Avatar**       | Path or name of speaker’s avatar image, e.g.`"res://avatars/alice.png"`or `"alice_avatar"`                 |
| **ItemRequired** | Item ID that player must have to see this line or to take a branch, e.g.`"keycard"`or empty if no requirement |
| **ItemGive**     | Comma-separated item IDs given to player on this line, e.g.`"coin,sword"`                                     |
| **Event**        | String event key to emit on this line, e.g.`"unlock_door"`or empty if none                                    |
