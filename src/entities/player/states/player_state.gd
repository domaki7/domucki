class_name PlayerState
extends State

var player: Player = null
var movement: MovementComponent = null
var animation: AnimationComponent = null
var stamina: StaminaComponent = null
var hitbox: HitboxComponent = null
var hurtbox: HurtboxComponent = null
var viewmodel: ViewmodelComponent = null

func _ready() -> void:
	await owner.ready
	player = owner as Player
	movement = player.movement_component
	animation = player.animation_component
	stamina = player.stamina_component
	hitbox = player.hitbox_component
	hurtbox = player.hurtbox_component
	viewmodel = player.viewmodel_component

func _is_input_enabled() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

func _check_jump() -> bool:
	if not _is_input_enabled():
		return false
	if Input.is_action_just_pressed(&"jump") and movement.body.is_on_floor():
		transition_requested.emit(self, &"JumpState")
		return true
	return false

func get_input_direction() -> Vector3:
	if not _is_input_enabled():
		return Vector3.ZERO
	var input: Vector2 = Vector2.ZERO
	input.x = Input.get_axis(&"move_left", &"move_right")
	input.y = Input.get_axis(&"move_forward", &"move_backward")

	if input.length() < 0.1:
		return Vector3.ZERO

	var cam_basis: Basis = player.get_camera_basis()
	var forward: Vector3 = -cam_basis.z
	var right: Vector3 = cam_basis.x

	forward.y = 0.0
	forward = forward.normalized()
	right.y = 0.0
	right = right.normalized()

	var direction: Vector3 = (forward * -input.y + right * input.x)
	return direction.normalized()
