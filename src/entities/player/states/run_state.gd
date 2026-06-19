class_name PlayerRunState
extends PlayerState

func enter() -> void:
	animation.play(&"Running_A", 0.2, true)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)

	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		movement.apply_movement(direction, delta)
	else:
		movement.apply_friction(delta)

	movement.move()

	if _check_jump():
		return

	if not movement.is_moving() and direction.length() < 0.1:
		transition_requested.emit(self, &"IdleState")
		return

	if Input.is_action_just_pressed(&"attack"):
		transition_requested.emit(self, &"AttackState")
		return

	if Input.is_action_just_pressed(&"defend"):
		transition_requested.emit(self, &"DefendState")
