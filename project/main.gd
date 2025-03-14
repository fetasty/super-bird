extends Node2D


const BARRIER = preload("res://barrier/barrier.tscn")

enum { STATE_WELCOME, STATE_PLAYING, STATE_PAUSE }


var score: int = 0:
	set(value):
		score = value
		hud_score.text = str(score)
		menu_score.text = str(score)
		score_container.visible = (value > 0)
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
			STATE_PLAYING:
				_hide_menu()
				_resume_game.call_deferred()
			STATE_PAUSE:
				_pause_game.call_deferred()
				_show_menu()
				start.visible = false
				resume.visible = true
				restart.visible = true
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


func _ready() -> void:
	var viewport_size = get_viewport().size / game_layer.scale.x
	bird.position = viewport_size * 0.5
	bird.collided.connect(_on_bird_collided)
	game_state = STATE_WELCOME


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if game_state == STATE_PLAYING:
			game_state = STATE_PAUSE


func _restart_game() -> void:
	for child in barriers.get_children():
		barriers.remove_child(child)
		child.queue_free()
	score = 0
	var viewport_size = get_viewport().size / game_layer.scale.x
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


func _on_bird_collided() -> void:
	game_state = STATE_WELCOME
	Logger.info("Bird collided!!!")


func _on_barrier_arrived_score_pos() -> void:
	score += 1
	Logger.info("Add score! Total score: %s" % score)


func _on_barrier_timer_timeout() -> void:
	var viewport_size = get_viewport().size / game_layer.scale.x
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
