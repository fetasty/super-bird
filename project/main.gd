extends Node2D


const BARRIER = preload("res://barrier/barrier.tscn")

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
				dynamic.game_restart()
				dynamic.game_pause()
			STATE_PLAYING:
				_hide_menu()
				_resume_game.call_deferred()
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

@onready var game_layer: CanvasLayer = $GameLayer
@onready var bird: Sprite2D = $GameLayer/Bird
@onready var barrier_timer: Timer = $GameLayer/BarrierTimer
@onready var barriers: Node2D = $GameLayer/Barriers
@onready var menu: Control = $UILayer/Menu
@onready var score_container: HBoxContainer = $UILayer/Menu/VBoxContainer/ScoreContainer
@onready var menu_score: Label = $UILayer/Menu/VBoxContainer/ScoreContainer/Score
@onready var start: Button = $UILayer/Menu/VBoxContainer/VBoxContainer/Start
@onready var resume: Button = $UILayer/Menu/VBoxContainer/VBoxContainer/Resume
@onready var restart: Button = $UILayer/Menu/VBoxContainer/VBoxContainer/Restart
@onready var hud_score: Label = $UILayer/HUD/HBoxContainer/Score
@onready var version_label: Label = $UILayer/Menu/VersionInfo/Version
@onready var mute_button: TextureButton = $UILayer/Menu/VolumeContainer/MuteButton
@onready var volume_slider: HSlider = $UILayer/Menu/VolumeContainer/VolumeSlider
@onready var dynamic: Node2D = $Dynamic


func _ready() -> void:
	var version = load("res://version.tres")
	version_label.text = version.version_str()
	barrier_timer.wait_time = Config.get_value("barrier_spawn_time", 1.0)
	AudioPlayer.volume_update = _volume_update
	var viewport_size = get_viewport_rect().size / game_layer.scale.x
	bird.position = viewport_size * 0.5
	bird.collided.connect(_on_bird_collided)
	game_state = STATE_WELCOME
	# 动态难度事件
	dynamic.level_changed.connect(_on_level_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if game_state == STATE_PLAYING:
			game_state = STATE_PAUSE


func _exit_tree() -> void:
	AudioPlayer.volume_update = Callable()


func _restart_game() -> void:
	for child in barriers.get_children():
		barriers.remove_child(child)
		child.queue_free()
	score = 0
	var viewport_size = get_viewport_rect().size / game_layer.scale.x
	bird.position = viewport_size * 0.5
	bird.reset()
	barrier_timer.start()
	game_state = STATE_PLAYING


func _show_menu() -> void:
	menu.visible = true


func _hide_menu() -> void:
	menu.visible = false


func _pause_game() -> void:
	game_layer.process_mode = Node.PROCESS_MODE_DISABLED


func _resume_game() -> void:
	game_layer.process_mode = Node.PROCESS_MODE_INHERIT


func _volume_update(mute: bool, volume: float) -> void:
	volume_slider.value = volume
	mute_button.button_pressed = mute


func _on_bird_collided() -> void:
	game_state = STATE_WELCOME
	Logger.info("Bird collided!!!")


func _on_barrier_arrived_score_pos() -> void:
	score += 1
	Logger.info("Add score! Total score: %s" % score)


func _on_level_changed(gravity: float, barrier_spawn_time: float, barrier_speed: float) -> void:
	Logger.info("Level changed: gravity(%s), barrier_spawn_time(%s), barrier_speed(%s)" % [gravity, barrier_spawn_time, barrier_speed])
	bird.change_gravity(gravity)
	Config.set_value("barrier_speed", barrier_speed) # TODO: 运行时生效配置, 需要与配置文件拆分
	for barrier in barriers.get_children():
		barrier.change_speed(barrier_speed)
	var tween = get_tree().create_tween()
	tween.tween_property(barrier_timer, "wait_time", barrier_spawn_time, 1.0)


func _on_barrier_timer_timeout() -> void:
	var viewport_size = get_viewport_rect().size / game_layer.scale.x
	var barrier = BARRIER.instantiate()
	barrier.arrived_score_pos.connect(_on_barrier_arrived_score_pos)
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
	AudioPlayer.set_mute(toggled_on)


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var volume = volume_slider.value
		AudioPlayer.set_volume(volume)
