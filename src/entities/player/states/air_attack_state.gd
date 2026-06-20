class_name PlayerAirAttackState
extends PlayerState

func enter() -> void:
	viewmodel.play_attack()
	viewmodel.attack_hit_point.connect(_on_attack_hit_point)
	viewmodel.attack_finished.connect(_on_attack_finished)

func exit() -> void:
	hitbox.deactivate()
	if viewmodel.attack_hit_point.is_connected(_on_attack_hit_point):
		viewmodel.attack_hit_point.disconnect(_on_attack_hit_point)
	if viewmodel.attack_finished.is_connected(_on_attack_finished):
		viewmodel.attack_finished.disconnect(_on_attack_finished)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)

	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		movement.apply_movement(direction, delta)
	else:
		movement.apply_friction(delta)

	movement.move()

func _on_attack_hit_point() -> void:
	hitbox.activate()

func _on_attack_finished() -> void:
	hitbox.deactivate()
	if movement.body.is_on_floor():
		var direction: Vector3 = get_input_direction()
		if direction.length() > 0.1:
			transition_requested.emit(self, &"RunState")
		else:
			transition_requested.emit(self, &"IdleState")
	else:
		var jump_state: PlayerJumpState = get_parent().get_node(^"JumpState") as PlayerJumpState
		jump_state.return_to_air = true
		transition_requested.emit(self, &"JumpState")
