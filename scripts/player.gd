extends CharacterBody2D

const BASE_SPEED := 150.0
const MAX_SPEED := 210.0
const GRAVITY := 980.0
const JUMP_VELOCITY := -380.0
const HIGH_JUMP_MULT := 1.6
const COYOTE_TIME := 0.12
const JUMP_BUFFER := 0.12

const SPRINT_MULT := 1.8
const SPRINT_DURATION := 1.2
const SPRINT_INVINCIBLE := 0.5
const SPRINT_COOLDOWN := 6.0

const HIGH_JUMP_COOLDOWN := 5.0

const SHIELD_DURATION := 8.0
const SHIELD_COOLDOWN := 10.0

const HIT_INVINCIBLE := 1.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var skill_particles: CPUParticles2D = $SkillParticles
@onready var shield_bubble: Sprite2D = $ShieldBubble

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _run_speed := BASE_SPEED
var _speed_ramp := 0.0

var _sprinting := false
var _sprint_timer := 0.0
var _sprint_cooldown := 0.0
var _sprint_invincible_timer := 0.0

var _high_jump_ready := false
var _high_jump_cooldown := 0.0
var _high_jump_active := false

var _shield_active := false
var _shield_timer := 0.0
var _shield_cooldown := 0.0

var _invincible_timer := 0.0
var _hurt_timer := 0.0
var _was_on_floor := true


func _ready() -> void:
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animation_finished)
	shield_bubble.visible = false
	skill_particles.emitting = false
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_stopped)
	GameManager.returned_to_title.connect(_on_game_stopped)


func _on_game_started() -> void:
	_reset_skills()
	_run_speed = BASE_SPEED
	_speed_ramp = 0.0
	sprite.play("run")
	_invincible_timer = 0.0
	_hurt_timer = 0.0


func _on_game_stopped(_arg = null) -> void:
	velocity = Vector2.ZERO
	sprite.play("idle")
	_sprinting = false
	_shield_active = false
	shield_bubble.visible = false
	skill_particles.emitting = false


func _physics_process(delta: float) -> void:
	if not GameManager.is_playing():
		if not is_on_floor():
			velocity.y += GRAVITY * delta
			velocity.x = 0.0
			move_and_slide()
		return

	_update_timers(delta)
	_handle_skills_input()
	_apply_gravity(delta)
	_handle_jump()
	_apply_horizontal_speed(delta)
	_update_animation()
	move_and_slide()
	_check_floor_state()


func _update_timers(delta: float) -> void:
	if _coyote_timer > 0.0:
		_coyote_timer -= delta
	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer -= delta
	if _sprint_cooldown > 0.0:
		_sprint_cooldown -= delta
	if _high_jump_cooldown > 0.0:
		_high_jump_cooldown -= delta
	if _shield_cooldown > 0.0:
		_shield_cooldown -= delta
	if _invincible_timer > 0.0:
		_invincible_timer -= delta
	if _hurt_timer > 0.0:
		_hurt_timer -= delta

	if _sprinting:
		_sprint_timer -= delta
		_sprint_invincible_timer -= delta
		if _sprint_timer <= 0.0:
			_sprinting = false
			skill_particles.emitting = false
			_sprint_cooldown = SPRINT_COOLDOWN

	if _shield_active:
		_shield_timer -= delta
		if _shield_timer <= 0.0:
			_deactivate_shield(true)

	if _invincible_timer <= 0.0 and _hurt_timer <= 0.0:
		sprite.modulate = Color.WHITE
	elif int(Time.get_ticks_msec() / 100) % 2 == 0:
		sprite.modulate = Color(1, 1, 1, 0.45)


func _handle_skills_input() -> void:
	if _hurt_timer > 0.0:
		return
	if Input.is_action_just_pressed("skill_sprint"):
		_try_sprint()
	if Input.is_action_just_pressed("skill_highjump"):
		_try_high_jump()
	if Input.is_action_just_pressed("skill_shield"):
		_try_shield()


func _try_sprint() -> void:
	if _sprint_cooldown > 0.0 or _sprinting:
		return
	_sprinting = true
	_sprint_timer = SPRINT_DURATION
	_sprint_invincible_timer = SPRINT_INVINCIBLE
	skill_particles.emitting = true
	sprite.play("sprint")
	AudioManager.play_sfx("sprint")


func _try_high_jump() -> void:
	if _high_jump_cooldown > 0.0 or _high_jump_ready:
		return
	_high_jump_ready = true
	_high_jump_active = true
	sprite.play("highjump")
	AudioManager.play_sfx("hop")


func _try_shield() -> void:
	if _shield_cooldown > 0.0 or _shield_active:
		return
	_shield_active = true
	_shield_timer = SHIELD_DURATION
	shield_bubble.visible = true
	shield_bubble.modulate = Color(1, 0.75, 0.9, 0.55)
	AudioManager.play_sfx("shield")


func _deactivate_shield(start_cooldown: bool = false) -> void:
	_shield_active = false
	shield_bubble.visible = false
	if start_cooldown:
		_shield_cooldown = SHIELD_COOLDOWN


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		_coyote_timer = COYOTE_TIME


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER

	var can_jump := is_on_floor() or _coyote_timer > 0.0
	if _jump_buffer_timer > 0.0 and can_jump:
		var jump_power := JUMP_VELOCITY
		var used_high_jump := _high_jump_ready
		if used_high_jump:
			jump_power *= HIGH_JUMP_MULT
			_high_jump_ready = false
			_high_jump_cooldown = HIGH_JUMP_COOLDOWN
		velocity.y = jump_power
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		sprite.play("jump_start")
		AudioManager.play_sfx("jump", 1.15 if used_high_jump else 1.0)


func _apply_horizontal_speed(delta: float) -> void:
	_speed_ramp += delta * 2.0
	_run_speed = min(BASE_SPEED + _speed_ramp * 8.0, MAX_SPEED)
	var speed := _run_speed
	if _sprinting:
		speed *= SPRINT_MULT
	velocity.x = speed


func _update_animation() -> void:
	if _hurt_timer > 0.0:
		return
	if _sprinting and sprite.animation != "sprint":
		sprite.play("sprint")
		return
	if not is_on_floor():
		if velocity.y < -40.0:
			if sprite.animation != "jump_start" and sprite.animation != "highjump":
				sprite.play("jump_air")
		else:
			sprite.play("fall")
	elif sprite.animation in ["jump_start", "jump_air", "fall", "highjump"]:
		sprite.play("run")
	elif sprite.animation not in ["run", "sprint"]:
		sprite.play("run")


func _check_floor_state() -> void:
	if is_on_floor() and not _was_on_floor:
		if _high_jump_ready:
			_high_jump_ready = false
			_high_jump_cooldown = HIGH_JUMP_COOLDOWN
		_high_jump_active = false
	_was_on_floor = is_on_floor()


func _on_animation_finished() -> void:
	if not GameManager.is_playing():
		return
	if sprite.animation in ["hurt", "highjump", "jump_start", "land"]:
		sprite.play("run")


func take_hit() -> void:
	if _invincible_timer > 0.0:
		return
	if _sprint_invincible_timer > 0.0:
		return
	if _shield_active:
		_deactivate_shield()
		_shield_cooldown = SHIELD_COOLDOWN
		_invincible_timer = 0.8
		AudioManager.play_sfx("shield_break")
		return

	GameManager.take_damage()
	_hurt_timer = 0.4
	_invincible_timer = HIT_INVINCIBLE
	sprite.play("hurt")
	velocity.y = -180.0
	AudioManager.play_sfx("hurt")


func is_invincible() -> bool:
	return _invincible_timer > 0.0 or _sprint_invincible_timer > 0.0


func get_sprint_cooldown_ratio() -> float:
	if _sprinting:
		return 0.0
	if SPRINT_COOLDOWN <= 0.0:
		return 0.0
	return clamp(_sprint_cooldown / SPRINT_COOLDOWN, 0.0, 1.0)


func get_highjump_cooldown_ratio() -> float:
	if _high_jump_ready:
		return 0.0
	return clamp(_high_jump_cooldown / HIGH_JUMP_COOLDOWN, 0.0, 1.0)


func get_shield_cooldown_ratio() -> float:
	if _shield_active:
		return 0.0
	return clamp(_shield_cooldown / SHIELD_COOLDOWN, 0.0, 1.0)


func is_shield_active() -> bool:
	return _shield_active


func _reset_skills() -> void:
	_sprinting = false
	_sprint_timer = 0.0
	_sprint_cooldown = 0.0
	_sprint_invincible_timer = 0.0
	_high_jump_ready = false
	_high_jump_cooldown = 0.0
	_high_jump_active = false
	_shield_active = false
	_shield_timer = 0.0
	_shield_cooldown = 0.0
