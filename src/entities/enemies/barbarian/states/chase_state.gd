class_name EnemyChaseState
extends EnemyState

@export var attack_range: float = 2.0
@export var give_up_range: float = 15.0

func enter() -> void:
	animation.play(&"Running_A", 0.2, true)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)

	var distance: float = get_distance_to_player()

	if distance <= attack_range:
		transition_requested.emit(self, &"AttackState")
		return

	if distance > give_up_range:
		transition_requested.emit(self, &"IdleState")
		return

	var direction: Vector3 = get_direction_to_player()
	if direction.length() > 0.01:
		movement.apply_movement(direction, delta)

	movement.move()
