extends Control

@onready var score_label: Label = $Panel/VBox/ScoreLabel
@onready var retry_button: Button = $Panel/VBox/RetryButton
@onready var title_button: Button = $Panel/VBox/TitleButton


func _ready() -> void:
	visible = false
	retry_button.pressed.connect(_on_retry)
	title_button.pressed.connect(_on_title)


func show_screen(final_score: int) -> void:
	visible = true
	score_label.text = "Score: %d\nNice run, cutie!" % final_score


func _on_retry() -> void:
	AudioManager.play_sfx("ui_click")
	visible = false
	GameManager.start_game()


func _on_title() -> void:
	AudioManager.play_sfx("ui_click")
	visible = false
	GameManager.return_to_title()
