class_name PlayerDefendState
extends PlayerState

func enter() -> void:
	player.start_defend()
	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		animation.play(&"Walking_A", 0.2, true)
	else:
		animation.play(&"Idle", 0.2, true)

func exit() -> void:
	player.stop_defend()

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)

	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		movement.apply_movement(direction * 0.5, delta)
		animation.play(&"Walking_A", 0.2, true)
	else:
		movement.apply_friction(delta)
		animation.play(&"Idle", 0.2, true)

	movement.move()

	if not Input.is_action_pressed(&"defend"):
		if direction.length() > 0.1:
			transition_requested.emit(self, &"RunState")
		else:
			transition_requested.emit(self, &"IdleState")
