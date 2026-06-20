class_name PlayerDefendState
extends PlayerState

func enter() -> void:
	viewmodel.raise_shield()

func exit() -> void:
	viewmodel.lower_shield()

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)

	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		movement.apply_movement(direction * 0.5, delta)
	else:
		movement.apply_friction(delta)

	movement.move()

	if _check_jump():
		return

	if not Input.is_action_pressed(&"defend"):
		if direction.length() > 0.1:
			transition_requested.emit(self, &"RunState")
		else:
			transition_requested.emit(self, &"IdleState")
