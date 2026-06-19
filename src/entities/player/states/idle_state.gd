class_name PlayerIdleState
extends PlayerState

func enter() -> void:
	animation.play(&"Idle")

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)
	movement.move()

	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		transition_requested.emit(self, &"RunState")
		return

	if Input.is_action_just_pressed(&"attack"):
		transition_requested.emit(self, &"AttackState")
