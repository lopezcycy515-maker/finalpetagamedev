extends ParallaxLayer

## Builds a seamless horizontal tile row for true parallax scrolling.

@export var tile_texture: Texture2D
@export var tiles_across: int = 10
@export var layer_y: float = 0.0


func _ready() -> void:
	if tile_texture == null:
		return

	var tile_w := tile_texture.get_width()
	motion_mirroring = Vector2(tile_w * tiles_across, 0.0)

	for i in range(tiles_across):
		var tile := Sprite2D.new()
		tile.texture = tile_texture
		tile.centered = false
		tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tile.position = Vector2(i * tile_w, layer_y)
		add_child(tile)
