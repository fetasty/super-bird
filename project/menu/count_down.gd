extends Control


signal finished

var count = 3

@onready var label: Label = $Label
@onready var timer: Timer = $Timer


func start() -> void:
	visible = true
	count = 3
	timer.start()
	set_count()
	AudioPlayer.play_start_beeps()


func set_count() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(label, "scale", Vector2(0.0, 0.0), 0.1)
	label.text = ("%s" % count) if count > 0 else "Go!"
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)


func _on_timer_timeout() -> void:
	if count > 0:
		count -= 1
		set_count()
	else:
		timer.stop()
		visible = false
		finished.emit()
