extends Control

@onready var resume_button: Button = $Panel/VBox/ResumeButton
@onready var restart_button: Button = $Panel/VBox/RestartButton
@onready var title_button: Button = $Panel/VBox/TitleButton


func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)
	title_button.pressed.connect(_on_title)


func show_menu() -> void:
	visible = true


func hide_menu() -> void:
	visible = false


func _on_resume() -> void:
	AudioManager.play_sfx("ui_click")
	hide_menu()
	GameManager.resume_game()


func _on_restart() -> void:
	AudioManager.play_sfx("ui_click")
	hide_menu()
	GameManager.start_game()


func _on_title() -> void:
	AudioManager.play_sfx("ui_click")
	hide_menu()
	GameManager.return_to_title()
