extends Area2D
class_name hitboxComponent

@export var attack_damage := 1
@export var knockback : Vector2 = Vector2(0, 0)

@export var activate_on_start : bool = false

var already_hit = []

func activate():
	print("Activated")
	already_hit.clear()
	monitoring = true

func deactivate():
	print("deactivated")
	monitoring = false

func _ready() -> void:
	monitoring = false
	if activate_on_start:
		activate()
	else:
		return

func _on_area_entered(area) -> void:
	
	if area in already_hit:
		return
	
	if area is HurtboxComponent:
		var hitbox : HurtboxComponent = area
		
		var dir = 1
		if global_position.x < hitbox.global_position.x:
			dir = 1
		else:
			dir = -1
		
		var final_knockback = Vector2(knockback.x * dir, knockback.y)
		
		hitbox.damage(attack_damage, final_knockback)
		already_hit.append(area)
