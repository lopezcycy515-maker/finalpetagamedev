extends Node

const SFX := {
	"jump": preload("res://assets/audio/jump.wav"),
	"hurt": preload("res://assets/audio/hurt.wav"),
	"sprint": preload("res://assets/audio/sprint.wav"),
	"hop": preload("res://assets/audio/hop.wav"),
	"shield": preload("res://assets/audio/shield.wav"),
	"shield_break": preload("res://assets/audio/shield_break.wav"),
	"pass": preload("res://assets/audio/pass.wav"),
	"ui_click": preload("res://assets/audio/ui_click.wav"),
}

const BGM := preload("res://assets/audio/bgm_loop.wav")

const POOL_SIZE := 8

var _bgm_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_index := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_bgm()
	_setup_sfx_pool()
	play_title_bgm()


func _setup_bgm() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	add_child(_bgm_player)
	if BGM:
		var stream := BGM.duplicate() as AudioStreamWAV
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_bgm_player.stream = stream


func _setup_sfx_pool() -> void:
	for i in range(POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % i
		player.volume_db = -4.0
		add_child(player)
		_sfx_pool.append(player)


func play_sfx(sfx_name: String, pitch_scale: float = 1.0) -> void:
	if not SFX.has(sfx_name):
		return
	var player := _sfx_pool[_sfx_index]
	_sfx_index = (_sfx_index + 1) % POOL_SIZE
	player.stream = SFX[sfx_name]
	player.pitch_scale = pitch_scale
	player.play()


func play_title_bgm() -> void:
	if _bgm_player == null:
		return
	_bgm_player.volume_db = -16.0
	if not _bgm_player.playing:
		_bgm_player.play()
	_bgm_player.stream_paused = false


func play_game_bgm() -> void:
	if _bgm_player == null:
		return
	_bgm_player.volume_db = -10.0
	if not _bgm_player.playing:
		_bgm_player.play()
	_bgm_player.stream_paused = false


func pause_bgm() -> void:
	if _bgm_player and _bgm_player.playing:
		_bgm_player.stream_paused = true


func resume_bgm() -> void:
	if _bgm_player and _bgm_player.playing:
		_bgm_player.stream_paused = false


func stop_bgm() -> void:
	if _bgm_player:
		_bgm_player.stop()
