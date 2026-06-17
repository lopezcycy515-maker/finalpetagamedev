extends Node2D

const SPAWN_MIN_DISTANCE := 280.0
const FIRST_SPAWN_DELAY := 3.5

const OBSTACLE_SCENES := {
	"cupcake": preload("res://scenes/obstacles/cupcake.tscn"),
	"teddy": preload("res://scenes/obstacles/teddy.tscn"),
	"ribbon": preload("res://scenes/obstacles/ribbon.tscn"),
	"flower_pot": preload("res://scenes/obstacles/flower_pot.tscn"),
	"heart": preload("res://scenes/obstacles/floating_heart.tscn"),
}

const WEIGHTS := {
	"cupcake": 30,
	"teddy": 20,
	"ribbon": 25,
	"flower_pot": 20,
	"heart": 5,
}

@export var ground_y: float = 344.0

var _last_spawn_x := 0.0
var _spawn_timer := 0.0
var _started := false
var _difficulty := 0.0


func _ready() -> void:
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_stopped)
	GameManager.returned_to_title.connect(_on_game_stopped)


func _on_game_started() -> void:
	_started = true
	_spawn_timer = FIRST_SPAWN_DELAY
	_difficulty = 0.0
	_clear_obstacles()
	var player := get_tree().get_first_node_in_group("player") as Node2D
	_last_spawn_x = player.global_position.x if player else 0.0


func _on_game_stopped(_arg = null) -> void:
	_started = false
	_clear_obstacles()


func _clear_obstacles() -> void:
	for child in get_children():
		child.queue_free()


func _process(delta: float) -> void:
	if not _started or not GameManager.is_playing():
		return

	_difficulty += delta * 0.05
	_spawn_timer -= delta

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var spawn_x: float = player.global_position.x + 500.0 + randf() * 80.0

	if _spawn_timer <= 0.0 and spawn_x - _last_spawn_x >= SPAWN_MIN_DISTANCE:
		_spawn_obstacle(spawn_x)
		_last_spawn_x = spawn_x
		var interval: float = max(2.2 - _difficulty * 0.3, 1.4)
		_spawn_timer = interval


func _spawn_obstacle(x: float) -> void:
	var kind: String = _pick_weighted()
	var scene: PackedScene = OBSTACLE_SCENES[kind]
	var obs := scene.instantiate()
	obs.global_position = Vector2(x, ground_y)
	if kind == "heart":
		obs.global_position.y -= 20.0
	add_child(obs)


func _pick_weighted() -> String:
	var total: int = 0
	for w in WEIGHTS.values():
		total += w
	var roll := randi() % total
	var acc: int = 0
	for k in WEIGHTS.keys():
		acc += WEIGHTS[k]
		if roll < acc:
			return k
	return "cupcake"
