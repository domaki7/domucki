class_name EnemyDeathState
extends EnemyState

func enter() -> void:
	animation.play(&"Death_A", 0.1)
	animation.animation_finished.connect(_on_animation_finished)

	enemy.collision_layer = 0
	enemy.collision_mask = 0
	enemy.hurtbox_component.monitoring = false
	hitbox.deactivate()

func exit() -> void:
	if animation.animation_finished.is_connected(_on_animation_finished):
		animation.animation_finished.disconnect(_on_animation_finished)

func _on_animation_finished(_anim_name: StringName) -> void:
	enemy.queue_free()
