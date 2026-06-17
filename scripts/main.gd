extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var title_screen: Control = $UI/TitleScreen
@onready var hud: Control = $UI/HUD
@onready var pause_menu: Control = $UI/PauseMenu
@onready var game_over_screen: Control = $UI/GameOverScreen
@onready var tutorial_label: Label = $UI/HUD/TutorialLabel


func _ready() -> void:
	_show_title()
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)
	GameManager.returned_to_title.connect(_on_returned_to_title)
	GameManager.pause_menu_open.connect(_on_pause_open)
	GameManager.pause_menu_close.connect(_on_pause_close)


func _on_pause_open() -> void:
	pause_menu.show_menu()


func _on_pause_close() -> void:
	pause_menu.hide_menu()


func _show_title() -> void:
	title_screen.visible = true
	hud.visible = false
	pause_menu.visible = false
	game_over_screen.visible = false


func _on_game_started() -> void:
	title_screen.visible = false
	hud.visible = true
	pause_menu.visible = false
	game_over_screen.visible = false
	tutorial_label.show_tutorial()
	if player:
		player.global_position = Vector2(150, 344)
		player.velocity = Vector2.ZERO


func _on_game_over(score: int) -> void:
	hud.visible = false
	game_over_screen.show_screen(score)


func _on_returned_to_title() -> void:
	_show_title()
	if player:
		player.global_position = Vector2(150, 344)
		player.velocity = Vector2.ZERO
