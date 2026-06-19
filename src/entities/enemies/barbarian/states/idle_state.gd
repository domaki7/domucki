class_name EnemyIdleState
extends EnemyState

@export var detection_range: float = 10.0

func enter() -> void:
	animation.play(&"Idle", 0.2, true)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)
	movement.apply_friction(delta)
	movement.move()

	if get_distance_to_player() <= detection_range:
		transition_requested.emit(self, &"ChaseState")
