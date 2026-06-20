extends CanvasLayer

@onready var _health_bar: HealthBar = $HUDRoot/TopLeft/VBoxContainer/HealthBar
@onready var _stamina_bar: HealthBar = $HUDRoot/TopLeft/VBoxContainer/StaminaBar

var _player: CharacterBody3D = null
var _health_component: HealthComponent = null
var _stamina_component: StaminaComponent = null

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
		_stamina_component = typed_player.stamina_component
	if _health_component:
		_health_component.health_changed.connect(_on_health_changed)
		_health_bar.update_health(_health_component.current_health, _health_component.max_health)
	if _stamina_component:
		_stamina_component.stamina_changed.connect(_on_stamina_changed)
		_stamina_bar.update_health(_stamina_component.current_stamina, _stamina_component.max_stamina)

func _unbind_player() -> void:
	if _health_component and is_instance_valid(_health_component):
		if _health_component.health_changed.is_connected(_on_health_changed):
			_health_component.health_changed.disconnect(_on_health_changed)
	if _stamina_component and is_instance_valid(_stamina_component):
		if _stamina_component.stamina_changed.is_connected(_on_stamina_changed):
			_stamina_component.stamina_changed.disconnect(_on_stamina_changed)
	_player = null
	_health_component = null
	_stamina_component = null

func _on_player_registered(player_node: CharacterBody3D) -> void:
	_bind_to_player(player_node)

func _on_health_changed(_old_value: float, new_value: float) -> void:
	if _health_component:
		_health_bar.update_health(new_value, _health_component.max_health)

func _on_stamina_changed(_old_value: float, new_value: float) -> void:
	if _stamina_component:
		_stamina_bar.update_health(new_value, _stamina_component.max_stamina)
