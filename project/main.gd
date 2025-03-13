extends Node2D


const BARRIER = preload("res://barrier/barrier.tscn")


var score: int = 0


@onready var game_layer: CanvasLayer = $GameLayer
@onready var bird: Sprite2D = $GameLayer/Bird
@onready var barrier_timer: Timer = $GameLayer/BarrierTimer
@onready var barriers: Node2D = $GameLayer/Barriers


func _ready() -> void:
	var viewport_size = get_viewport().size / game_layer.scale.x
	bird.position = viewport_size * 0.5
	bird.reset()
	bird.collided.connect(_on_bird_collided)
	barrier_timer.start()




func _on_bird_collided() -> void:
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
