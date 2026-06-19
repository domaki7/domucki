class_name PlayerJumpState
extends PlayerState

enum Phase { START, AIR, LAND }

var _phase: Phase = Phase.START
var return_to_air: bool = false

func enter() -> void:
	animation.animation_finished.connect(_on_animation_finished)
	if return_to_air:
		return_to_air = false
		_phase = Phase.AIR
		animation.play(&"Jump_Idle", 0.1, true)
	else:
		_phase = Phase.START
		movement.apply_jump_impulse()
		animation.play(&"Jump_Start", 0.1)

func exit() -> void:
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

	if _phase == Phase.AIR:
		if movement.body.is_on_floor():
			_phase = Phase.LAND
			animation.play(&"Jump_Land", 0.1)
			return

		if Input.is_action_just_pressed(&"attack"):
			transition_requested.emit(self, &"AirAttackState")

func _on_animation_finished(_anim_name: StringName) -> void:
	match _phase:
		Phase.START:
			_phase = Phase.AIR
			animation.play(&"Jump_Idle", 0.2, true)
		Phase.LAND:
			var direction: Vector3 = get_input_direction()
			if direction.length() > 0.1:
				transition_requested.emit(self, &"RunState")
			else:
				transition_requested.emit(self, &"IdleState")
