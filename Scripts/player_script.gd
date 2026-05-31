extends CharacterBody2D

# --- REFERENCES ---
@onready var attack_pivot: Node2D = $AttackPivot
@onready var hurt_box: Area2D = $AttackPivot/HitboxComponent
@onready var hitbox: hitboxComponent = $AttackPivot/HitboxComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# SLASHES

@onready var slash_animation: AnimatedSprite2D = $Slashes/slash_animation

# --- MOVEMENT SETTINGS ---
@export var speed := 100.0
@export var acceleration := 1000.0
@export var friction := 1500.0

# --- JUMP SETTINGS ---
@export var jump_velocity := -350.0
@export var fall_gravity_multiplier := 1.0
@export var air_control := 0.7

# --- COYOTE + BUFFER ---
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.1

# --- STATE ---
var coyote_timer := 0.0
var jump_buffer_timer := 0.0

enum jump_state {GROUNDED, TAKE_OFF, PEAK, FALLING}

var base_velocity = Vector2.ZERO
var knockback_vel = Vector2.ZERO

var can_attack = true
var is_attacking = false
enum Attack_state {UP, DOWN, FROWARD, NULL}
var attack_state : Attack_state = Attack_state.NULL

# --- INPUT CACHE (future AI-ready) ---
var move_input := 0.0
var jump_pressed := false
var jump_released := false
var attack_pressed := false
var up_or_down := 0.0

# --- ATTACK SETTINGS ---
var attack_duration := 0.1
var attack_cooldown := 0.2 

func _physics_process(delta: float) -> void:
	read_input()
	handle_movement(delta)
	apply_gravity(delta)
	handle_jump(delta)
	handle_attack()
	handle_animations()
	
	velocity = base_velocity + knockback_vel
	knockback_vel = knockback_vel.move_toward(Vector2(0, 0), 900 * delta)
	move_and_slide()


# =========================
# INPUT
# =========================
func read_input():
	move_input = Input.get_axis("left", "right")
	jump_pressed = Input.is_action_just_pressed("jump")
	jump_released = Input.is_action_just_released("jump")
	attack_pressed = Input.is_action_just_pressed("attack")
	up_or_down = Input.get_axis("down", "up")


# =========================
# MOVEMENT
# =========================
func handle_movement(delta):
	
	var controll = 1
	
	if move_input != 0:
		if is_on_floor():
			base_velocity.x = move_toward(
				base_velocity.x, 
				move_input * speed, acceleration * controll * delta
				)
				
		else:
			base_velocity.x = move_toward(
				base_velocity.x,
				move_input * speed, acceleration * air_control * controll * delta
				)
	else:
		base_velocity.x = move_toward(base_velocity.x, 0, friction * delta)

func apply_knockback(force : Vector2):
	knockback_vel += force


# =========================
# GRAVITY
# =========================
func apply_gravity(delta):
	if not is_on_floor():
		if base_velocity.y > 0:
			base_velocity.y += global.gravity * fall_gravity_multiplier * delta
		else:
			base_velocity.y += global.gravity * delta
	else:
		base_velocity.y = 0


# =========================
# JUMP
# =========================
func handle_jump(delta):
	# Coyote time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Jump buffer
	if jump_pressed:
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# Jump
	if jump_buffer_timer > 0 and coyote_timer > 0:
		base_velocity.y = jump_velocity
		#spawn_burst(0.4)
		jump_buffer_timer = 0
		coyote_timer = 0

	# Short hop
	if jump_released and base_velocity.y < 0:
		base_velocity.y *= 0.5
		
	if is_on_ceiling():
		base_velocity.y = 70
		get_viewport().get_camera_2d().shake(0.7)


# =========================
# ATTACK
# =========================

func handle_attack():
	if attack_pressed and can_attack:
		attack()
	elif not is_attacking:
		attack_state = Attack_state.NULL
	

func do_slash(Flip_h : bool, state : Attack_state):
	
	if state == Attack_state.FROWARD:
		slash_animation.rotation_degrees = 0
		slash_animation.flip_h = Flip_h
		slash_animation.flip_v = false
		slash_animation.play("forward")
		
	elif state == Attack_state.UP:
		if Flip_h:
			animation_player.play("slash_up_left")
		else:
			animation_player.play("slash_up_right")
		slash_animation.play("forward")
		
	elif state == Attack_state.DOWN:
		if Flip_h:
			animation_player.play("slash_down_left")
		else:
			animation_player.play("slash_down_right")
		slash_animation.play("forward")

func manage_attack_animation():
	
	print(up_or_down)
	
	if up_or_down < 0 and not is_on_floor():
		attack_pivot.rotation_degrees = 90
		animated_sprite.play("down_slash")
		attack_state = Attack_state.DOWN
		do_pogo()
		
	elif up_or_down > 0:
		attack_pivot.rotation_degrees = -90
		animated_sprite.play("up_slash")
		attack_state = Attack_state.UP
		
	else:
		animated_sprite.play("forward_slash")
		attack_state = Attack_state.FROWARD
		if animated_sprite.flip_h:
			attack_pivot.rotation_degrees = 180
			
		else:
			attack_pivot.rotation_degrees = 0
	
	do_slash(animated_sprite.flip_h, attack_state)
	await animated_sprite.animation_finished

func do_pogo():
	pass

func attack():
	can_attack = false
	is_attacking = true
		
	manage_attack_animation()
	
	hitbox.activate()
	print("Atack")
	await get_tree().create_timer(attack_duration).timeout

	hitbox.deactivate()
	await get_tree().create_timer(attack_cooldown).timeout
	
	is_attacking = false
	can_attack = true
	

# =========================
# ANIMATIONS
# =========================

func handle_animations():
	if move_input < 0:
		animated_sprite.flip_h = true
		animated_sprite.offset.x = 20
	elif move_input > 0:
		animated_sprite.flip_h = false
		animated_sprite.offset.x = 0 
		
	if is_attacking:
		return
		
	if not is_on_floor():
		var JUMP_STATE = get_jump_state()
		
		if JUMP_STATE == jump_state.PEAK:
			animated_sprite.play("peak")
			
		elif JUMP_STATE == jump_state.TAKE_OFF:
			animated_sprite.play("take_off")
			
		else:
			animated_sprite.play("falling")
		
		
	elif abs(velocity.x) > 5:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
		
func get_jump_state() -> jump_state:
	
	if is_on_floor():
		return jump_state.GROUNDED
	
	elif velocity.y < 300 and velocity.y > 0:
		return jump_state.PEAK
		
	elif velocity.y < 0:
		return jump_state.TAKE_OFF
		
	else:
		return jump_state.FALLING


# =========================
# UPON HIT
# =========================

func upon_hit(health):
	sprite.modulate.g = 100
	
