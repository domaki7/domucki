extends CanvasLayer

@onready var _health_bar: HealthBar = $HUDRoot/TopLeft/HealthBar

var _player: CharacterBody3D = null
var _health_component: HealthComponent = null

func _ready() -> void:
	GameManager.player_registered.connect(_on_player_registered)
	if GameManager.player:
		_bind_to_player(GameManager.player)

func _bind_to_player(player_node: CharacterBody3D) -> void:
	_unbind_player()
	_player = player_node
	var typed_player: Player = _player as Player
	if typed_player:
		_health_component = typed_player.health_component
	if _health_component:
		_health_component.health_changed.connect(_on_health_changed)
		_health_bar.update_health(_health_component.current_health, _health_component.max_health)

func _unbind_player() -> void:
	if _health_component and is_instance_valid(_health_component):
		if _health_component.health_changed.is_connected(_on_health_changed):
			_health_component.health_changed.disconnect(_on_health_changed)
	_player = null
	_health_component = null

func _on_player_registered(player_node: CharacterBody3D) -> void:
	_bind_to_player(player_node)

func _on_health_changed(_old_value: float, new_value: float) -> void:
	if _health_component:
		_health_bar.update_health(new_value, _health_component.max_health)
