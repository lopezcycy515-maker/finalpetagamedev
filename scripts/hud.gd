extends Control

@onready var score_label: Label = $ScoreLabel
@onready var hearts_container: HBoxContainer = $HeartsContainer
@onready var sprint_btn: PanelContainer = $SkillBar/SprintBtn
@onready var hop_btn: PanelContainer = $SkillBar/HopBtn
@onready var shield_btn: PanelContainer = $SkillBar/ShieldBtn
@onready var sprint_cd: ProgressBar = $SkillBar/SprintBtn/VBox/Cooldown
@onready var hop_cd: ProgressBar = $SkillBar/HopBtn/VBox/Cooldown
@onready var shield_cd: ProgressBar = $SkillBar/ShieldBtn/VBox/Cooldown

var _heart_tex: Texture2D = preload("res://assets/sprites/ui/heart.png")


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	_on_score_changed(GameManager.score)
	_on_lives_changed(GameManager.lives)


func _process(_delta: float) -> void:
	if not visible:
		return
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null or not player.has_method("get_sprint_cooldown_ratio"):
		return
	sprint_cd.value = (1.0 - player.get_sprint_cooldown_ratio()) * 100.0
	hop_cd.value = (1.0 - player.get_highjump_cooldown_ratio()) * 100.0
	shield_cd.value = (1.0 - player.get_shield_cooldown_ratio()) * 100.0
	_update_skill_style(sprint_btn, player.get_sprint_cooldown_ratio() <= 0.0)
	_update_skill_style(hop_btn, player.get_highjump_cooldown_ratio() <= 0.0)
	_update_skill_style(shield_btn, player.get_shield_cooldown_ratio() <= 0.0 or player.is_shield_active())


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score


func _on_lives_changed(lives: int) -> void:
	for child in hearts_container.get_children():
		child.queue_free()
	for i in range(lives):
		var heart := TextureRect.new()
		heart.texture = _heart_tex
		heart.custom_minimum_size = Vector2(28, 28)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hearts_container.add_child(heart)


func _update_skill_style(btn: PanelContainer, ready: bool) -> void:
	btn.modulate = Color.WHITE if ready else Color(0.82, 0.82, 0.88, 0.9)
