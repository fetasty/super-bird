extends Node2D

const BARRIER_HITBOX: PackedScene = preload("res://barrier/barrier_hitbox.tscn")
const BODY_SIZE: Vector2 = Vector2(17, 5)
const HEAD_SIZE: Vector2 = Vector2(28, 9)
const BREAK_PARTICAL = preload("res://barrier/break_partical.tscn")

signal arrived_score_pos

## init before add to scene tree
var resource: BarrierResource = null

# 移动速度
var _move_speed: float = 150
# 计分位置
var _score_pos_x: float = 288
# 释放位置
var _release_pos_x: float = -10
# 通路宽度
var _passage_width: int = 70


# 上半部分柱子数量
var _upper_size_min: int = 3
var _upper_size_max: int = 37
var _upper_size: int = 20 # 随机
var _arrived_score_pos: bool = false

var _game_layer_scale: float = 2.0

@onready var upper_parts: Node2D = $UpperParts
@onready var lower_parts: Node2D = $LowerParts


func _ready() -> void:
	_load_config()
	_rebuild_barrier()
	GameData.config_changed.connect(_on_config_changed)


func _physics_process(delta: float) -> void:
	position.x -= _move_speed * delta
	if not _arrived_score_pos and position.x <= _score_pos_x:
		_arrived_score_pos = true
		arrived_score_pos.emit()
	if position.x < _release_pos_x:
		queue_free()


func _change_speed(speed: float) -> void:
	_move_speed = speed


func _load_config() -> void:
	_move_speed = GameData.get_config("barrier_speed")
	_game_layer_scale = GameData.get_config("game_layer_scale")
	_score_pos_x = GameData.get_config("barrier_score_pos") * get_viewport_rect().size.x / _game_layer_scale
	_release_pos_x = GameData.get_config("barrier_release_pos")
	_passage_width = GameData.get_config("barrier_passage_width")
	_upper_size_min = GameData.get_config("barrier_upper_size_min")
	_upper_size_max = GameData.get_config("barrier_upper_size_max")


## rebuild barrier
func _rebuild_barrier() -> void:
	# random upper part size
	_upper_size = randi_range(_upper_size_min, _upper_size_max)
	# clear all barriers
	for child in upper_parts.get_children():
		child.queue_free()
		upper_parts.remove_child(child)
	for child in lower_parts.get_children():
		child.queue_free()
		lower_parts.remove_child(child)
	# build upper part
	for i in range(0, _upper_size - 1):
		var body = Sprite2D.new()
		body.texture = resource.body_texture
		body.name = "UpperBody%s" % i
		body.position = Vector2(0, BODY_SIZE.y * (i + 0.5))
		upper_parts.add_child(body)
	if _upper_size > 0:
		var head = Sprite2D.new()
		head.texture = resource.head_texture
		head.name = "UpperHead"
		head.position = Vector2(0, BODY_SIZE.y * (_upper_size - 1) + HEAD_SIZE.y * 0.5)
		upper_parts.add_child(head)
	# calculate lower part size
	var screen_size = get_viewport_rect().size / _game_layer_scale
	var lower_screen_size = screen_size.y - (BODY_SIZE.y * (_upper_size - 1) + HEAD_SIZE.y + _passage_width)
	var lower_size = 0
	if lower_screen_size >= HEAD_SIZE.y:
		lower_size += 1
		lower_screen_size -= HEAD_SIZE.y
	lower_size += int(lower_screen_size / BODY_SIZE.y)
	# build lower part
	for i in range(0, lower_size - 1):
		var body = Sprite2D.new()
		body.texture = resource.body_texture
		body.name = "LowerBody%s" % i
		body.position = Vector2(0, screen_size.y - BODY_SIZE.y * (i + 0.5))
		lower_parts.add_child(body)
	if lower_size > 0:
		var head = Sprite2D.new()
		head.texture = resource.head_texture
		head.name = "LowerHead"
		head.position = Vector2(0, screen_size.y - BODY_SIZE.y * (lower_size - 1) - HEAD_SIZE.y * 0.5)
		lower_parts.add_child(head)
	# build collision box
	if _upper_size > 1:
		var upper_body_box = BARRIER_HITBOX.instantiate()
		upper_body_box.name = "UpperBodyBox"
		upper_body_box.box_size = Vector2(BODY_SIZE.x - 2, BODY_SIZE.y * (_upper_size - 1))
		upper_body_box.position = Vector2(0, upper_body_box.box_size.y * 0.5)
		upper_body_box.set_meta("type", resource.key)
		upper_body_box.area_entered.connect(_on_upper_part_collided)
		upper_parts.add_child(upper_body_box)
	if _upper_size > 0:
		var upper_head_box = BARRIER_HITBOX.instantiate()
		upper_head_box.name = "UpperHeadBox"
		upper_head_box.box_size = Vector2(HEAD_SIZE.x - 2, HEAD_SIZE.y - 2)
		upper_head_box.position = Vector2(0, BODY_SIZE.y * (_upper_size - 1) + HEAD_SIZE.y * 0.5)
		upper_head_box.set_meta("type", resource.key)
		upper_head_box.area_entered.connect(_on_upper_part_collided)
		upper_parts.add_child(upper_head_box)
	if lower_size > 1:
		var lower_body_box = BARRIER_HITBOX.instantiate()
		lower_body_box.name = "LowerBodyBox"
		lower_body_box.box_size = Vector2(BODY_SIZE.x - 2, BODY_SIZE.y * (lower_size - 1))
		lower_body_box.position = Vector2(0, screen_size.y - lower_body_box.box_size.y * 0.5)
		lower_body_box.set_meta("type", resource.key)
		lower_body_box.area_entered.connect(_on_lower_part_collided)
		lower_parts.add_child(lower_body_box)
	if lower_size > 0:
		var lower_head_box = BARRIER_HITBOX.instantiate()
		lower_head_box.name = "LowerHeadBox"
		lower_head_box.box_size = Vector2(HEAD_SIZE.x - 2, HEAD_SIZE.y - 2)
		lower_head_box.position = Vector2(0, screen_size.y - BODY_SIZE.y * (lower_size - 1) - HEAD_SIZE.y * 0.5)
		lower_head_box.set_meta("type", resource.key)
		lower_head_box.area_entered.connect(_on_lower_part_collided)
		lower_parts.add_child(lower_head_box)


func _on_config_changed(key: String, value: Variant) -> void:
	match key:
		"barrier_speed":
			_change_speed(value)
		_:
			pass


func _on_upper_part_collided(_area: Area2D) -> void:
	Logger.info("Upper part collided!")
	# TODO 从GameData中获取player的buff状态
	match resource.key:
		"barrier_iron":
			pass
		"barrier_wood":
			pass
		"barrier_grass":
			var partical = BREAK_PARTICAL.instantiate()
			add_child(partical)
			partical.global_position = _area.global_position
			partical.restart()
			for child in upper_parts.get_children():
				child.queue_free()


func _on_lower_part_collided(_area: Area2D) -> void:
	Logger.info("Lower part collided!")
	# TODO 从GameData中获取player的buff状态
	match resource.key:
		"barrier_iron":
			pass
		"barrier_wood":
			pass
		"barrier_grass":
			var partical = BREAK_PARTICAL.instantiate()
			add_child(partical)
			partical.global_position = _area.global_position
			partical.restart()
			for child in lower_parts.get_children():
				child.queue_free()
