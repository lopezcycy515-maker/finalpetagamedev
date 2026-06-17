extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal game_started
signal game_over(final_score: int)
signal returned_to_title
signal pause_menu_open
signal pause_menu_close
signal obstacle_passed
signal player_hit

enum State { TITLE, PLAYING, PAUSED, GAME_OVER }

const MAX_LIVES := 3

var state: State = State.TITLE
var score: int = 0
var lives: int = MAX_LIVES

var _score_accumulator: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if state != State.PLAYING:
		return
	_score_accumulator += delta * 10.0
	if _score_accumulator >= 1.0:
		var points := int(_score_accumulator)
		_score_accumulator -= points
		add_score(points)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if state == State.PLAYING:
		pause_game()
		pause_menu_open.emit()
	elif state == State.PAUSED:
		resume_game()
		pause_menu_close.emit()


func start_game() -> void:
	get_tree().paused = false
	score = 0
	lives = MAX_LIVES
	state = State.PLAYING
	_score_accumulator = 0.0
	score_changed.emit(score)
	lives_changed.emit(lives)
	game_started.emit()
	AudioManager.play_game_bgm()


func pause_game() -> void:
	if state == State.PLAYING:
		state = State.PAUSED
		get_tree().paused = true
		AudioManager.pause_bgm()


func resume_game() -> void:
	if state == State.PAUSED:
		state = State.PLAYING
		get_tree().paused = false
		AudioManager.resume_bgm()


func end_game() -> void:
	if state == State.GAME_OVER:
		return
	state = State.GAME_OVER
	get_tree().paused = false
	AudioManager.play_title_bgm()
	game_over.emit(score)


func return_to_title() -> void:
	state = State.TITLE
	score = 0
	lives = MAX_LIVES
	get_tree().paused = false
	score_changed.emit(score)
	lives_changed.emit(lives)
	returned_to_title.emit()
	AudioManager.play_title_bgm()


func add_score(points: int) -> void:
	if state != State.PLAYING:
		return
	score += points
	score_changed.emit(score)


func register_obstacle_passed() -> void:
	if state != State.PLAYING:
		return
	add_score(10)
	obstacle_passed.emit()
	AudioManager.play_sfx("pass")


func take_damage() -> void:
	if state != State.PLAYING:
		return
	lives = max(lives - 1, 0)
	lives_changed.emit(lives)
	player_hit.emit()
	if lives <= 0:
		end_game()


func is_playing() -> bool:
	return state == State.PLAYING
