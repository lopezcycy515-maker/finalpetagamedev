extends Area2D

@export var obstacle_type: String = "cupcake"

var _passed := false
var _hit_player := false
var _base_y := 0.0
var _bob_time := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if obstacle_type == "heart":
		_base_y = position.y
		_bob_time = randf() * TAU


func _physics_process(delta: float) -> void:
	if obstacle_type == "heart" and GameManager.is_playing():
		_bob_time += delta
		position.y = _base_y + sin(_bob_time * 2.0) * 12.0

	if _passed:
		return
	if not GameManager.is_playing():
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	if global_position.x < player.global_position.x - 30.0:
		_passed = true
		if not _hit_player:
			GameManager.register_obstacle_passed()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_hit"):
		_hit_player = true
		body.take_hit()
