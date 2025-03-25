extends VBoxContainer

## Must be setted before adding to scenetree
var role_res: PlayerResource

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label


func _ready() -> void:
	texture_rect.texture = role_res.texture
	label.text = role_res.key


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		GameData.set_data("last_player_role", role_res.key)
