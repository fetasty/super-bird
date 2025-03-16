extends Node2D

var _is_mute: bool = false
var _back_volume: float = 0.0
var _effect_volume: float = 0.0

var _is_play_welcome: bool = true
var _is_play_background: bool = true
var _is_play_effect: bool = true

@onready var welcom_audio: AudioStreamPlayer = $WelcomAudio
@onready var background_audio: AudioStreamPlayer = $BackgroundAudio
@onready var jump_audio: AudioStreamPlayer = $JumpAudio
@onready var hit_audio: AudioStreamPlayer = $HitAudio


func _ready() -> void:
	# load config
	_is_mute = Config.get_value("audio_mute", false)
	_back_volume = Config.get_value("back_volume", 0.0)
	_effect_volume = Config.get_value("effect_volume", 0.0)


func set_welcome_play(enable: bool) -> void:
	_is_play_welcome = enable
	if _is_play_welcome and not _is_mute:
		welcom_audio.play()
	else:
		welcom_audio.stop()


func set_background_play(enable: bool) -> void:
	_is_play_background = enable
	if _is_play_background and not _is_mute:
		background_audio.play()
	else:
		background_audio.stop()


func play_jump() -> void:
	if _is_mute or _is_play_effect:
		return
	jump_audio.play()


func play_hit() -> void:
	if _is_mute or _is_play_effect:
		return
	hit_audio.play()


func _on_welcom_audio_finished() -> void:
	if _is_play_welcome and not _is_mute:
		await get_tree().create_timer(randf_range(3, 10)).timeout
		if _is_play_welcome and not _is_mute:
			welcom_audio.play()


func _on_background_audio_finished() -> void:
	if _is_play_background and not _is_mute:
		await get_tree().create_timer(randf_range(3, 10)).timeout
		if _is_play_background and not _is_mute:
			background_audio.play()
