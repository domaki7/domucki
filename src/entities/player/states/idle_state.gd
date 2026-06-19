class_name PlayerIdleState
extends PlayerState

func enter() -> void:
	animation.play(&"Idle", 0.2, true)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)
	movement.move()

	if _check_jump():
		return

	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		transition_requested.emit(self, &"RunState")
		return

	if Input.is_action_just_pressed(&"attack"):
		transition_requested.emit(self, &"AttackState")
		return

	if Input.is_action_just_pressed(&"defend"):
		transition_requested.emit(self, &"DefendState")
