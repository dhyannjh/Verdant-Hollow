extends Camera2D

@export var target: Node2D

var shake_strength := 0.0
var shake_decay := 10.0

func _process(delta):
	
	# --- FOLLOW PLAYER ---
	if target:
		global_position = target.global_position
		
	# --- SCREEN SHAKE ---
	if shake_strength > 0:
		offset = Vector2(
			randf_range(shake_strength, -shake_strength),
			randf_range(shake_strength, -shake_strength)
		)
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
		
	else:
		offset = Vector2.ZERO

# --- TRIGGER SCREEN SHAKE FUNCTION ---

func shake(amount: float):
	shake_strength = max(shake_strength, amount)
