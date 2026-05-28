extends Node2D
class_name HealthComponent

var health 
@export var max_health := 5

func _ready() -> void:
	health = max_health
	
func take_damage(damage):
	health -= damage
	
	if health <= 0:
		get_parent().queue_free()
	
