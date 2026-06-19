class_name PlayerAirAttackState
extends PlayerState

func enter() -> void:
	animation.play(&"1H_Melee_Attack_Slice_Diagonal", 0.1)
	animation.animation_finished.connect(_on_animation_finished)
	hitbox.activate()

func exit() -> void:
	hitbox.deactivate()
	if animation.animation_finished.is_connected(_on_animation_finished):
		animation.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)

	var direction: Vector3 = get_input_direction()
	if direction.length() > 0.1:
		movement.apply_movement(direction, delta)
	else:
		movement.apply_friction(delta)

	movement.move()

func _on_animation_finished(_anim_name: StringName) -> void:
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
