class_name PlayerSprintState
extends PlayerState

const SPRINT_SPEED_MULTIPLIER: float = 1.8

func enter() -> void:
	stamina.is_sprinting = true
	animation.play(&"Running_B", 0.2, true)
	viewmodel.set_bobbing(true)
	player.camera_arm.set_sprint_fov(true)

func exit() -> void:
	stamina.is_sprinting = false
	viewmodel.set_bobbing(false)
	player.camera_arm.set_sprint_fov(false)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)

	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		movement.apply_movement(direction * SPRINT_SPEED_MULTIPLIER, delta)
	else:
		movement.apply_friction(delta)

	movement.move()

	if _check_jump():
		return

	if stamina.current_stamina <= 0.0:
		if direction.length() > 0.1:
			transition_requested.emit(self, &"RunState")
		else:
			transition_requested.emit(self, &"IdleState")
		return

	if not Input.is_action_pressed(&"sprint"):
		if direction.length() > 0.1:
			transition_requested.emit(self, &"RunState")
		else:
			transition_requested.emit(self, &"IdleState")
		return

	if not movement.is_moving() and direction.length() < 0.1:
		transition_requested.emit(self, &"IdleState")
		return

	if _is_input_enabled() and Input.is_action_just_pressed(&"attack"):
		transition_requested.emit(self, &"AttackState")
		return

	if _is_input_enabled() and Input.is_action_just_pressed(&"defend"):
		transition_requested.emit(self, &"DefendState")
