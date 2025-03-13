extends Node2D

const BARRIER_BODY: PackedScene = preload("res://barrier/barrier_body.tscn")
const BARRIER_HEAD: PackedScene = preload("res://barrier/barrier_head.tscn")
const BARRIER_HITBOX: PackedScene = preload("res://barrier/barrier_hitbox.tscn")
const BODY_SIZE: Vector2 = Vector2(17, 5)
const HEAD_SIZE: Vector2 = Vector2(28, 9)

signal arrived_score_pos

# 移动速度
var move_speed: float = 100
# 计分位置
var score_pos_x: float = 288
# 释放位置
var release_pos_x: float = -10
# 通路宽度
var passage_width: int = 50


# 上半部分柱子数量
var _upper_size: int = 20 # 5 - 35 随机
var _arrived_score_pos: bool = false


func _ready() -> void:
	rebuild_barrier()


func _physics_process(delta: float) -> void:
	position.x -= move_speed * delta
	if not _arrived_score_pos and position.x <= score_pos_x:
		_arrived_score_pos = true
		arrived_score_pos.emit()
	if position.x < release_pos_x:
		queue_free()


## 重新随机构建一个障碍柱
func rebuild_barrier() -> void:
	# 随机取一个上半部分柱子数量
	_upper_size = randi_range(5, 35)
	# 先删除以前的构建
	for child in get_children():
		child.queue_free()
		remove_child(child)
	# 构建上半部分柱子
	for i in range(0, _upper_size - 1):
		var body = BARRIER_BODY.instantiate()
		body.name = "UpperBody%s" % i
		body.position = Vector2(0, BODY_SIZE.y * (i + 0.5))
		add_child(body)
	if _upper_size > 0:
		var head = BARRIER_HEAD.instantiate()
		head.name = "UpperHead"
		head.position = Vector2(0, BODY_SIZE.y * (_upper_size - 1) + HEAD_SIZE.y * 0.5)
		add_child(head)
	# 计算下半部分柱子数量
	var screen_size = get_viewport().size * 0.25 # 放大4倍, 屏幕像素区域只有原来的1/4大小
	var lower_screen_size = screen_size.y - (BODY_SIZE.y * (_upper_size - 1) + HEAD_SIZE.y + passage_width)
	var lower_size = 0
	if lower_screen_size >= HEAD_SIZE.y:
		lower_size += 1
		lower_screen_size -= HEAD_SIZE.y
	lower_size += int(lower_screen_size / BODY_SIZE.y)
	# 构建下半部分柱子
	for i in range(0, lower_size - 1):
		var body = BARRIER_BODY.instantiate()
		body.name = "LowerBody%s" % i
		body.position = Vector2(0, screen_size.y - BODY_SIZE.y * (i + 0.5))
		add_child(body)
	if lower_size > 0:
		var head = BARRIER_HEAD.instantiate()
		head.name = "LowerHead"
		head.position = Vector2(0, screen_size.y - BODY_SIZE.y * (lower_size - 1) - HEAD_SIZE.y * 0.5)
		add_child(head)
	# 构建碰撞盒
	if _upper_size > 1:
		var upper_body_box = BARRIER_HITBOX.instantiate()
		upper_body_box.name = "UpperBodyBox"
		upper_body_box.box_size = Vector2(BODY_SIZE.x - 2, BODY_SIZE.y * (_upper_size - 1))
		upper_body_box.position = Vector2(0, upper_body_box.box_size.y * 0.5)
		add_child(upper_body_box)
	if _upper_size > 0:
		var upper_head_box = BARRIER_HITBOX.instantiate()
		upper_head_box.name = "UpperHeadBox"
		upper_head_box.box_size = Vector2(HEAD_SIZE.x - 2, HEAD_SIZE.y - 2)
		upper_head_box.position = Vector2(0, BODY_SIZE.y * (_upper_size - 1) + HEAD_SIZE.y * 0.5)
		add_child(upper_head_box)
	if lower_size > 1:
		var lower_body_box = BARRIER_HITBOX.instantiate()
		lower_body_box.name = "LowerBodyBox"
		lower_body_box.box_size = Vector2(BODY_SIZE.x - 2, BODY_SIZE.y * (lower_size - 1))
		lower_body_box.position = Vector2(0, screen_size.y - lower_body_box.box_size.y * 0.5)
		add_child(lower_body_box)
	if lower_size > 0:
		var lower_head_box = BARRIER_HITBOX.instantiate()
		lower_head_box.name = "LowerHeadBox"
		lower_head_box.box_size = Vector2(HEAD_SIZE.x - 2, HEAD_SIZE.y - 2)
		lower_head_box.position = Vector2(0, screen_size.y - BODY_SIZE.y * (lower_size - 1) - HEAD_SIZE.y * 0.5)
		add_child(lower_head_box)


func pause() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func resume() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
