class_name EnemyState
extends State

var enemy: Barbarian = null
var movement: MovementComponent = null
var animation: AnimationComponent = null
var hitbox: HitboxComponent = null

func _ready() -> void:
	await owner.ready
	enemy = owner as Barbarian
	movement = enemy.movement_component
	animation = enemy.animation_component
	hitbox = enemy.hitbox_component

func get_player() -> CharacterBody3D:
	return GameManager.player

func get_distance_to_player() -> float:
	var player: CharacterBody3D = get_player()
	if not player:
		return INF
	return enemy.global_position.distance_to(player.global_position)

func get_direction_to_player() -> Vector3:
	var player: CharacterBody3D = get_player()
	if not player:
		return Vector3.ZERO
	var direction: Vector3 = player.global_position - enemy.global_position
	direction.y = 0.0
	if direction.length() < 0.01:
		return Vector3.ZERO
	return direction.normalized()
