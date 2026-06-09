extends CharacterBody2D

#=== REFERENCES ===
@onready var color_rect: ColorRect = $ColorRect

# --- STATE ---
var base_velocity = Vector2.ZERO
var knockback_vel = Vector2.ZERO


# =========================
# LOOP
# =========================
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	velocity = base_velocity + knockback_vel
	knockback_vel = knockback_vel.move_toward(Vector2(0, 0), 900 * delta)
	move_and_slide()

# =========================
# GRAVITY
# =========================
func apply_gravity(delta):
	if not is_on_floor():
		base_velocity.y += global.gravity * delta
	else:
		base_velocity.y = 0


# =========================
# UPON HIT
# =========================

func upon_hit(health):
	color_rect.modulate.g = 0.5
	color_rect.modulate.b = 0.5
	print(self, " hit")
	
	await get_tree().create_timer(0.1).timeout
	
	color_rect.modulate.g = 1
	color_rect.modulate.b = 1
	
func apply_knockback(force : Vector2):
	knockback_vel += force
