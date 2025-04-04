extends Node2D


const BARRIER = preload("res://barrier/barrier.tscn")
const ROLE_ITEM = preload("res://role_item.tscn")

enum { STATE_WELCOME, STATE_PLAYING, STATE_PAUSE }


var score: int = 0:
	set(value):
		score = value
		hud_score.text = str(score)
		menu_score.text = str(score)
		# score_container.visible = (value > 0)
	get:
		return score

var game_state: int = STATE_WELCOME:
	set(value):
		game_state = value
		match value:
			STATE_WELCOME:
				_pause_game.call_deferred()
				_show_menu()
				start.visible = true
				resume.visible = false
				restart.visible = false
				AudioPlayer.set_welcome_play(true)
				AudioPlayer.set_background_play(false)
				dynamic.game_pause()
			STATE_PLAYING:
				_resume_game.call_deferred()
				_hide_menu()
				AudioPlayer.set_welcome_play(false)
				AudioPlayer.set_background_play(true)
				dynamic.game_resume()
			STATE_PAUSE:
				_pause_game.call_deferred()
				_show_menu()
				start.visible = false
				resume.visible = true
				restart.visible = true
				AudioPlayer.set_welcome_play(true)
				AudioPlayer.set_background_play(false)
				dynamic.game_pause()
	get:
		return game_state

var _game_layer_scale: float = 2.0

@onready var game_layer: CanvasLayer = $GameLayer
@onready var player: Node2D = $GameLayer/Player
@onready var barrier_timer: Timer = $GameLayer/BarrierTimer
@onready var barriers: Node2D = $GameLayer/Barriers
@onready var menu: Control = $UILayer/Menu
@onready var score_container: HBoxContainer = $UILayer/Menu/VBoxContainer/ScoreContainer
@onready var menu_score: Label = $UILayer/Menu/VBoxContainer/ScoreContainer/Score
@onready var start: Button = $UILayer/Menu/VBoxContainer/VBoxContainer/Start
@onready var resume: Button = $UILayer/Menu/VBoxContainer/VBoxContainer/Resume
@onready var restart: Button = $UILayer/Menu/VBoxContainer/VBoxContainer/Restart
@onready var hud_score: Label = $UILayer/HUD/HBoxContainer/Score
@onready var version_label: Label = $UILayer/Menu/VBoxContainer2/VersionInfo/Version
@onready var mute_button: TextureButton = $UILayer/Menu/VBoxContainer/VBoxContainer/Control/VolumeContainer/MuteButton
@onready var volume_slider: HSlider = $UILayer/Menu/VBoxContainer/VBoxContainer/Control/VolumeContainer/VolumeSlider
@onready var dynamic: Node2D = $Dynamic
@onready var role_select: Control = $UILayer/Menu/RoleSelect
@onready var role_items: HBoxContainer = $UILayer/Menu/RoleSelect/RoleItems
@onready var selected_border: TextureRect = $UILayer/Menu/RoleSelect/SelectedBorder
@onready var guide: Control = $UILayer/Guide
@onready var count_down_button: CheckButton = $UILayer/Menu/VBoxContainer/VBoxContainer/CountDown
@onready var count_down: Control = $UILayer/CountDown


func _ready() -> void:
	_game_init()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if game_state == STATE_PLAYING:
			game_state = STATE_PAUSE


func _load_config() -> void:
	_game_layer_scale = GameData.get_config("game_layer_scale")
	barrier_timer.wait_time = GameData.get_config("barrier_spawn_time")
	mute_button.button_pressed = GameData.get_data("audio_mute")
	volume_slider.value = GameData.get_data("audio_volume")
	game_layer.scale = Vector2(_game_layer_scale, _game_layer_scale)


func _game_init() -> void:
	# version info display
	var version = load("res://version.tres")
	version_label.text = version.version_str()
	# count down button
	count_down_button.button_pressed = GameData.get_data("show_count_down")
	# reset game scene and game data
	_reset_game()
	# roles
	var res_dict := GameData.player_res_dict()
	for k in res_dict:
		var role := ROLE_ITEM.instantiate()
		role.role_res = res_dict[k]
		role.selected_border = selected_border
		role_items.add_child(role)
	# bind signals
	player.player_collided_with_wall.connect(_on_player_collided)
	GameData.config_changed.connect(_on_config_changed)
	GameData.data_changed.connect(_on_data_changed)
	# init game state
	game_state = STATE_WELCOME


func _reset_game() -> void:
	GameData.reset_config()
	_load_config()
	# clean the scene
	for child in barriers.get_children():
		barriers.remove_child(child)
		child.queue_free()
	# reset player position
	var viewport_size = get_viewport_rect().size / _game_layer_scale
	player.position = viewport_size * 0.5
	# reset player state
	player.reset()
	# reset score
	score = 0
	# reset dynamic difficulty
	dynamic.game_reset()


func _restart_game() -> void:
	var show_count_down = GameData.get_data("show_count_down")
	if show_count_down:
		menu.visible = false
		count_down.start()
		await count_down.finished
	_reset_game()
	game_state = STATE_PLAYING


func _show_menu() -> void:
	menu.visible = true


func _hide_menu() -> void:
	menu.visible = false


func _pause_game() -> void:
	game_layer.process_mode = Node.PROCESS_MODE_DISABLED


func _resume_game() -> void:
	game_layer.process_mode = Node.PROCESS_MODE_INHERIT


func _player_add_score(add_score: int) -> void:
	var double: bool = player.buff_status["double_score"]
	score += add_score * 2 if double else add_score
	Logger.info("Add score! Total score: %s" % score)


func _on_config_changed(key: String, value: Variant) -> void:
	match key:
		"barrier_spawn_time":
			barrier_timer.wait_time = value
		_:
			pass


func _on_data_changed(key: String, value: Variant) -> void:
	match key:
		"audio_mute":
			mute_button.set_pressed_no_signal(value)
		"audio_volume":
			volume_slider.set_value_no_signal(value)
		_:
			pass


func _on_player_collided() -> void:
	game_state = STATE_WELCOME
	AudioPlayer.play_hit()
	Logger.info("Player collided!!!")


func _on_barrier_arrived_score_pos() -> void:
	_player_add_score(1)


func _on_barrier_broken(broken_score: int) -> void:
	_player_add_score(broken_score)
	AudioPlayer.play_crack()


func _on_item_collided(buff: String) -> void:
	player.add_buff(buff)
	AudioPlayer.play_item()


func _on_level_changed(gravity: float, barrier_spawn_time: float, barrier_speed: float) -> void:
	Logger.info("Level changed: gravity(%s), barrier_spawn_time(%s), barrier_speed(%s)" % [gravity, barrier_spawn_time, barrier_speed])
	GameData.set_config("barrier_speed", barrier_speed)


func _on_barrier_timer_timeout() -> void:
	var viewport_size = get_viewport_rect().size / _game_layer_scale
	var barrier = BARRIER.instantiate()
	barrier.resource = GameData.random_barrier_res()
	barrier.arrived_score_pos.connect(_on_barrier_arrived_score_pos)
	barrier.player_collided_with_barrier.connect(_on_player_collided)
	barrier.barrier_broken.connect(_on_barrier_broken)
	barrier.item_collided.connect(_on_item_collided)
	barrier.position = Vector2(viewport_size.x, 0)
	barriers.add_child(barrier)


func _on_start_pressed() -> void:
	_restart_game()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	game_state = STATE_PLAYING


func _on_restart_pressed() -> void:
	_restart_game()


func _on_mute_button_toggled(toggled_on: bool) -> void:
	GameData.set_data("audio_mute", toggled_on)


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var volume = volume_slider.value
		GameData.set_data("audio_volume", volume)
		if volume < 0.1:
			GameData.set_data("audio_mute", true)
		else:
			GameData.set_data("audio_mute", false)


func _on_role_pressed() -> void:
	role_select.visible = true
	var last_role = GameData.get_data("last_player_role")
	# TODO role_item.show_border()
	match last_role:
		"chick":
			selected_border.global_position = Vector2(345.0, 221.0)
		"dog":
			selected_border.global_position = Vector2(445.0, 221.0)
		"pig":
			selected_border.global_position = Vector2(545.0, 221.0)


func _on_role_select_back_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		role_select.visible = false


func _on_show_guide_pressed() -> void:
	guide.visible = true


func _on_count_down_toggled(toggled_on: bool) -> void:
	GameData.set_data("show_count_down", toggled_on)
