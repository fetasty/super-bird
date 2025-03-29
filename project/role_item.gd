extends VBoxContainer

## Must be setted before adding to scenetree
var role_res: PlayerResource
var selected_border: TextureRect

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label


func _ready() -> void:
	texture_rect.texture = role_res.texture
	label.text = role_res.key
	var last_role = GameData.get_data("last_player_role")
	if last_role == role_res.key:
		show_border()


func show_border() -> void:
	selected_border.global_position = texture_rect.global_position + texture_rect.size * 0.5 - (selected_border.size * 0.5)
	Logger.info("select role %s, selected border pos: %s" % [role_res.key, selected_border.global_position])


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		GameData.set_data("last_player_role", role_res.key)
		show_border()
