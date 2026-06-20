class_name EnemyAttackState
extends EnemyState

func enter() -> void:
	animation.play(&"1H_Melee_Attack_Chop", 0.1)
	animation.animation_finished.connect(_on_animation_finished)
	hitbox.activate()
	hitbox.play_swing_tween()

func exit() -> void:
	hitbox.deactivate()
	hitbox.reset_position()
	if animation.animation_finished.is_connected(_on_animation_finished):
		animation.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)
	movement.apply_friction(delta)
	movement.move()

func _on_animation_finished(_anim_name: StringName) -> void:
	transition_requested.emit(self, &"ChaseState")
