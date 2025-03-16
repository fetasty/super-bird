extends Node2D


var volume_update: Callable:
	set(value):
		volume_update = value
		if volume_update.is_valid():
			volume_update.call(is_mute, audio_volume)

var is_mute: bool = false
var audio_volume: float = 1.0

var _is_play_welcome: bool = true
var _is_play_background: bool = true
var _is_play_effect: bool = true

@onready var welcom_audio: AudioStreamPlayer = $WelcomAudio
@onready var background_audio: AudioStreamPlayer = $BackgroundAudio
@onready var jump_audio: AudioStreamPlayer = $JumpAudio
@onready var hit_audio: AudioStreamPlayer = $HitAudio


func _ready() -> void:
	# load config
	var mute = Config.get_value("audio_mute", false)
	var volume = Config.get_value("audio_volume", 0.5)
	set_volume(volume)
	set_mute(mute)


func set_mute(mute: bool) -> void:
	if is_mute == mute:
		return
	is_mute = mute
	Config.set_value("audio_mute", mute)
	if volume_update.is_valid():
		volume_update.call(is_mute, audio_volume)
	if is_mute:
		welcom_audio.volume_linear = 0.0
		background_audio.volume_linear = 0.0
		jump_audio.volume_linear = 0.0
		hit_audio.volume_linear = 0.0
	else:
		welcom_audio.volume_linear = audio_volume
		background_audio.volume_linear = audio_volume
		jump_audio.volume_linear = audio_volume
		hit_audio.volume_linear = audio_volume


func set_volume(value: float) -> void:
	if is_equal_approx(value, audio_volume):
		return
	audio_volume = value
	if value < 0.1:
		if not is_mute:
			set_mute(true)
	else:
		if is_mute:
			set_mute(false)
		Config.set_value("audio_volume", value)
		welcom_audio.volume_linear = audio_volume
		background_audio.volume_linear = audio_volume
		jump_audio.volume_linear = audio_volume
		hit_audio.volume_linear = audio_volume
	if volume_update.is_valid():
		volume_update.call(is_mute, audio_volume)


func set_welcome_play(enable: bool) -> void:
	_is_play_welcome = enable
	if _is_play_welcome:
		welcom_audio.play()
	else:
		welcom_audio.stop()


func set_background_play(enable: bool) -> void:
	_is_play_background = enable
	if _is_play_background:
		background_audio.play()
	else:
		background_audio.stop()


func play_jump() -> void:
	if is_mute or not _is_play_effect:
		return
	jump_audio.play()


func play_hit() -> void:
	if is_mute or not _is_play_effect:
		return
	hit_audio.play()


func _on_welcom_audio_finished() -> void:
	if _is_play_welcome and not is_mute:
		await get_tree().create_timer(randf_range(3, 10)).timeout
		if _is_play_welcome and not is_mute:
			welcom_audio.play()


func _on_background_audio_finished() -> void:
	if _is_play_background and not is_mute:
		await get_tree().create_timer(randf_range(3, 10)).timeout
		if _is_play_background and not is_mute:
			background_audio.play()
