class_name PlayerIdleState
extends PlayerState

func enter() -> void:
	animation.play(&"Idle", 0.2, true)
	viewmodel.set_bobbing(false)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)
	movement.move()

	if _check_jump():
		return

	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		if _is_input_enabled() and Input.is_action_pressed(&"sprint") and stamina.current_stamina > 0.0:
			transition_requested.emit(self, &"SprintState")
		else:
			transition_requested.emit(self, &"RunState")
		return

	if _is_input_enabled() and Input.is_action_just_pressed(&"attack"):
		transition_requested.emit(self, &"AttackState")
		return

	if _is_input_enabled() and Input.is_action_just_pressed(&"defend"):
		transition_requested.emit(self, &"DefendState")
