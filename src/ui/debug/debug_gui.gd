extends Control

var _panel: PanelContainer
var _tab_container: TabContainer
var _viewmodel_tab: Control = null
var _stamina_tab: Control = null
var _combat_tab: Control = null

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)

	_tab_container = TabContainer.new()
	_tab_container.custom_minimum_size = Vector2(420, 0)
	_panel.add_child(_tab_container)

	_setup_anchors()

	GameManager.player_registered.connect(_on_player_registered)
	if GameManager.player:
		_bind_to_player(GameManager.player)

func _setup_anchors() -> void:
	_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_panel.offset_left = -440.0
	_panel.offset_top = 10.0
	_panel.offset_bottom = -10.0
	_panel.offset_right = -10.0

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_ALT and key_event.pressed and not key_event.echo:
			_toggle_panel()
			get_viewport().set_input_as_handled()

func _toggle_panel() -> void:
	visible = not visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		if _viewmodel_tab:
			_viewmodel_tab.on_panel_hidden()

func _on_player_registered(player_node: CharacterBody3D) -> void:
	_bind_to_player(player_node)

func _bind_to_player(player_node: CharacterBody3D) -> void:
	var typed_player: Player = player_node as Player
	if not typed_player:
		return

	if typed_player.viewmodel_component:
		if _viewmodel_tab:
			_viewmodel_tab.queue_free()
		var viewmodel_gui: Node = load("res://src/ui/debug/debug_viewmodel_gui.gd").new()
		viewmodel_gui.name = "Viewmodel"
		_tab_container.add_child(viewmodel_gui)
		viewmodel_gui.setup(typed_player.viewmodel_component)
		_viewmodel_tab = viewmodel_gui as Control

	if typed_player.stamina_component:
		if _stamina_tab:
			_stamina_tab.queue_free()
		var stamina_gui: Node = load("res://src/ui/debug/debug_stamina_gui.gd").new()
		stamina_gui.name = "Stamina"
		_tab_container.add_child(stamina_gui)
		stamina_gui.setup(typed_player.stamina_component, typed_player.camera_arm)
		_stamina_tab = stamina_gui as Control

	if typed_player.hitbox_component or typed_player.hurtbox_component:
		if _combat_tab:
			_combat_tab.queue_free()
		var combat_gui: Node = load("res://src/ui/debug/debug_combat_gui.gd").new()
		combat_gui.name = "Combat"
		_tab_container.add_child(combat_gui)
		combat_gui.setup(typed_player)
		_combat_tab = combat_gui as Control
