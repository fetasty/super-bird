extends Node2D

const DOG = preload("res://audios/dog.mp3")
const PIG = preload("res://audios/pig.mp3")
const CHICK = preload("res://audios/chick.mp3")

var is_mute: bool = false
var audio_volume: float = 1.0

var _is_play_welcome: bool = true
var _is_play_background: bool = true
var _is_play_effect: bool = true

@onready var welcom_audio: AudioStreamPlayer = $WelcomAudio
@onready var background_audio: AudioStreamPlayer = $BackgroundAudio
@onready var jump_audio: AudioStreamPlayer = $JumpAudio
@onready var hit_audio: AudioStreamPlayer = $HitAudio
@onready var item_audio: AudioStreamPlayer = $ItemAudio
@onready var crack_audio: AudioStreamPlayer = $CrackAudio
@onready var start_beeps: AudioStreamPlayer = $StartBeeps


func _ready() -> void:
	# load saved data
	var mute = GameData.get_data("audio_mute", false)
	var volume = GameData.get_data("audio_volume", 0.5)
	var role = GameData.get_data("last_player_role", "chick")
	set_volume(volume)
	set_mute(mute)
	set_player_role(role)
	# listen data changes
	GameData.data_changed.connect(_on_data_changed)


func set_mute(mute: bool) -> void:
	if is_mute == mute:
		return
	is_mute = mute
	if is_mute:
		welcom_audio.volume_linear = 0.0
		background_audio.volume_linear = 0.0
		jump_audio.volume_linear = 0.0
		hit_audio.volume_linear = 0.0
		item_audio.volume_linear = 0.0
		crack_audio.volume_linear = 0.0
		start_beeps.volume_linear = 0.0
	else:
		welcom_audio.volume_linear = audio_volume
		background_audio.volume_linear = audio_volume
		jump_audio.volume_linear = audio_volume
		hit_audio.volume_linear = audio_volume
		item_audio.volume_linear = audio_volume
		crack_audio.volume_linear = audio_volume
		start_beeps.volume_linear = audio_volume


func set_volume(value: float) -> void:
	if is_equal_approx(value, audio_volume):
		return
	audio_volume = value
	welcom_audio.volume_linear = audio_volume
	background_audio.volume_linear = audio_volume
	jump_audio.volume_linear = audio_volume
	hit_audio.volume_linear = audio_volume
	item_audio.volume_linear = audio_volume
	crack_audio.volume_linear = audio_volume
	start_beeps.volume_linear = audio_volume


func set_player_role(value: String) -> void:
	match value:
		"chick":
			jump_audio.stream = CHICK
		"dog":
			jump_audio.stream = DOG
		"pig":
			jump_audio.stream = PIG
		_:
			assert(false)
			pass


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
	if hit_audio.playing:
		return
	hit_audio.play()


func play_item() -> void:
	if is_mute or not _is_play_effect:
		return
	item_audio.play()


func play_crack() -> void:
	if is_mute or not _is_play_effect:
		return
	crack_audio.play()


func play_start_beeps() -> void:
	if is_mute or not _is_play_effect:
		return
	start_beeps.play()


func _on_data_changed(key: String, value: Variant) -> void:
	match key:
		"audio_mute":
			set_mute(value)
		"audio_volume":
			set_volume(value)
		"last_player_role":
			set_player_role(value)
		_:
			pass


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
