class_name PlayerAttackState
extends PlayerState

func enter() -> void:
	stamina.spend(stamina.attack_cost)
	viewmodel.play_attack()
	hitbox.play_swing_tween()
	viewmodel.attack_hit_point.connect(_on_attack_hit_point)
	viewmodel.attack_finished.connect(_on_attack_finished)

func exit() -> void:
	hitbox.deactivate()
	hitbox.reset_position()
	if viewmodel.attack_hit_point.is_connected(_on_attack_hit_point):
		viewmodel.attack_hit_point.disconnect(_on_attack_hit_point)
	if viewmodel.attack_finished.is_connected(_on_attack_finished):
		viewmodel.attack_finished.disconnect(_on_attack_finished)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)
	movement.apply_friction(delta)
	movement.move()

	if _check_jump():
		return

func _on_attack_hit_point() -> void:
	hitbox.activate()

func _on_attack_finished() -> void:
	hitbox.deactivate()
	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		transition_requested.emit(self, &"RunState")
	else:
		transition_requested.emit(self, &"IdleState")
