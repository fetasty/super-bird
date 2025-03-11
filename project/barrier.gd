extends Node2D

const BARRIER_BODY: PackedScene = preload("res://barrier_body.tscn")
const BARRIER_HEAD: PackedScene = preload("res://barrier_head.tscn")
const BODY_SIZE: Vector2 = Vector2(17, 5)
const HEAD_SIZE: Vector2 = Vector2(28, 9)

# 上半部分柱子数量
var upper_size: int = 20 # TODO 5 - 35 随机
# 通路宽度
var passage_width: int = 50

func _ready() -> void:
	_create_barrier()


func _create_barrier() -> void:
	# 构建上半部分柱子
	for i in range(0, upper_size - 1):
		var body = BARRIER_BODY.instantiate()
		body.name = "UpperBody%s" % i
		body.position = Vector2(0, BODY_SIZE.y * (i + 0.5))
		add_child(body)
	if upper_size > 0:
		var head = BARRIER_HEAD.instantiate()
		head.name = "UpperHead"
		head.position = Vector2(0, BODY_SIZE.y * (upper_size - 1) + HEAD_SIZE.y * 0.5)
		add_child(head)
	# 计算下半部分柱子数量
	var screen_size = get_viewport().size * 0.25 # 放大4倍, 屏幕像素区域只有原来的1/4大小
	var lower_screen_size = screen_size.y - (BODY_SIZE.y * (upper_size - 1) + HEAD_SIZE.y + passage_width)
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
