extends Node2D

const TILE_WIDTH := 32
const VISIBLE_TILES := 40

@onready var grass_tex: Texture2D = preload("res://assets/sprites/tiles/grass.png")
@onready var path_tex: Texture2D = preload("res://assets/sprites/tiles/path.png")

var _tiles: Array[Sprite2D] = []


func _ready() -> void:
	for i in range(VISIBLE_TILES):
		var s := Sprite2D.new()
		s.texture = path_tex if i % 3 == 1 else grass_tex
		s.position = Vector2(i * TILE_WIDTH, 0)
		s.centered = false
		s.offset = Vector2(0, 0)
		add_child(s)
		_tiles.append(s)


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var cam_x := player.global_position.x - 200.0
	var base_x := int(floor(cam_x / TILE_WIDTH)) * TILE_WIDTH
	for i in range(_tiles.size()):
		var tile := _tiles[i]
		tile.position.x = base_x + i * TILE_WIDTH
		tile.position.y = 0
