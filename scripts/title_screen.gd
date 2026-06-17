extends Control

@onready var play_button: Button = $Panel/VBox/PlayButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)


func _on_play_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	GameManager.start_game()
