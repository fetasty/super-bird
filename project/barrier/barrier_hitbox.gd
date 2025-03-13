extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

## 加入SceneTree之前初始化
var box_size: Vector2 = Vector2.ZERO


func _ready() -> void:
	collision_shape_2d.shape.size = box_size
	if box_size == Vector2.ZERO:
		Logger.warn("Barrier hitbox size is zero")
