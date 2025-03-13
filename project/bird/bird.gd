extends Sprite2D

## 发生了碰撞
signal collided

## 重力加速度
var gravity = 600.0
## 跳跃速度
var jump_velocity = 150

var _velocity = 0.0
var _is_jumping = false

@onready var timer: Timer = $Timer


func _physics_process(delta: float) -> void:
	if _is_jumping:
		_velocity = -jump_velocity
	else:
		_velocity += gravity * delta
	position.y += _velocity * delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_is_jumping = true
		timer.start()
	if event.is_action_released("jump"):
		_is_jumping = false
		timer.stop()


func pause() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func resume() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT


func _on_timer_timeout() -> void:
	_is_jumping = false


func _on_area_2d_area_entered(_area: Area2D) -> void:
	collided.emit()
