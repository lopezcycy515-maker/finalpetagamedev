extends Camera2D

const FIXED_Y := 314.0
const LOOK_AHEAD_X := 80.0


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0
	zoom = Vector2(1, 1)
	make_current()


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	global_position = Vector2(player.global_position.x + LOOK_AHEAD_X, FIXED_Y)
