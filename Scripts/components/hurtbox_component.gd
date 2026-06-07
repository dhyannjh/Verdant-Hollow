extends Area2D
class_name HurtboxComponent

@export var health_component : HealthComponent

func damage(damage, knockback : Vector2):
	if health_component:
		health_component.take_damage(damage)
		#get_parent().velocity += knockback
		
		print(str(get_parent()), " hit")
		
		if get_parent().has_method("apply_knockback"):
			get_parent().apply_knockback(knockback)
