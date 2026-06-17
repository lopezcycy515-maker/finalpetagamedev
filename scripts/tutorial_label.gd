extends Label

var _timer := 0.0


func show_tutorial() -> void:
	visible = true
	modulate.a = 1.0
	_timer = 6.0
	text = "Space = Jump  |  Z = Sparkle Sprint  |  X = Bunny Hop  |  C = Bubble Shield"


func _process(delta: float) -> void:
	if not visible:
		return
	_timer -= delta
	if _timer <= 1.0:
		modulate.a = clamp(_timer, 0.0, 1.0)
	if _timer <= 0.0:
		visible = false
