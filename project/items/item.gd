class_name Item extends Node2D

signal collided(buff: int)

var res: ItemResource

var _collided: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite_2d.texture = res.texture
	sprite_2d.scale = Vector2(res.scale, res.scale)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not _collided and area.has_meta("player"):
		_collided = true
		collided.emit(res.buff)
		queue_free()
