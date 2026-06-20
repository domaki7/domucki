extends Control

var _viewmodel: ViewmodelComponent = null
var _panel: PanelContainer
var _content: VBoxContainer

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(320, 0)
	_panel.add_child(scroll)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_content)

	_setup_anchors()

	GameManager.player_registered.connect(_on_player_registered)
	if GameManager.player:
		_bind_to_player(GameManager.player)

func _setup_anchors() -> void:
	_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_panel.offset_left = -340.0
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

func _on_player_registered(player_node: CharacterBody3D) -> void:
	_bind_to_player(player_node)

func _bind_to_player(player_node: CharacterBody3D) -> void:
	var typed_player: Player = player_node as Player
	if typed_player and typed_player.viewmodel_component:
		_viewmodel = typed_player.viewmodel_component
		_build_controls()

func _build_controls() -> void:
	for child: Node in _content.get_children():
		child.queue_free()

	_add_header("Sword Position")
	_add_vector3_control("sword_idle_position", -2.0, 2.0, 0.01)
	_add_vector3_control("sword_idle_rotation", -180.0, 180.0, 0.5)
	_add_vector3_control("sword_scale", 0.1, 5.0, 0.1)

	_add_header("Shield Position")
	_add_vector3_control("shield_idle_position", -2.0, 2.0, 0.01)
	_add_vector3_control("shield_idle_rotation", -180.0, 180.0, 0.5)
	_add_vector3_control("shield_scale", 0.1, 5.0, 0.1)

	_add_header("Bob")
	_add_float_control("bob_frequency", 0.0, 10.0, 0.1)
	_add_float_control("bob_amplitude", 0.0, 0.2, 0.005)

	_add_header("Attack")
	_add_float_control("attack_windup_duration", 0.01, 2.0, 0.01)
	_add_float_control("attack_swing_duration", 0.01, 2.0, 0.01)
	_add_float_control("attack_recovery_duration", 0.01, 2.0, 0.01)

	_add_header("Block")
	_add_float_control("shield_raise_duration", 0.01, 2.0, 0.01)
	_add_vector3_control("shield_raised_position", -2.0, 2.0, 0.01)
	_add_vector3_control("shield_raised_rotation", -180.0, 180.0, 0.5)

	_add_header("Death")
	_add_float_control("death_drop_duration", 0.01, 2.0, 0.01)

	var sep: HSeparator = HSeparator.new()
	_content.add_child(sep)

	var export_button: Button = Button.new()
	export_button.text = "Copy Values to Clipboard"
	export_button.pressed.connect(_on_export_pressed)
	_content.add_child(export_button)

func _add_header(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	_content.add_child(label)

	var sep: HSeparator = HSeparator.new()
	_content.add_child(sep)

func _add_float_control(property: String, min_val: float, max_val: float, step_val: float) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	_content.add_child(row)

	var label: Label = Label.new()
	label.text = property
	label.custom_minimum_size.x = 140.0
	label.add_theme_font_size_override("font_size", 12)
	row.add_child(label)

	var spinbox: SpinBox = SpinBox.new()
	spinbox.min_value = min_val
	spinbox.max_value = max_val
	spinbox.step = step_val
	spinbox.value = _viewmodel.get(property)
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spinbox.value_changed.connect(_on_float_changed.bind(property))
	row.add_child(spinbox)

func _add_vector3_control(property: String, min_val: float, max_val: float, step_val: float) -> void:
	var label: Label = Label.new()
	label.text = property
	label.add_theme_font_size_override("font_size", 12)
	_content.add_child(label)

	var row: HBoxContainer = HBoxContainer.new()
	_content.add_child(row)

	var current: Vector3 = _viewmodel.get(property)
	var axes: Array[String] = ["x", "y", "z"]
	var values: Array[float] = [current.x, current.y, current.z]

	for i: int in 3:
		var axis_label: Label = Label.new()
		axis_label.text = axes[i].to_upper()
		axis_label.add_theme_font_size_override("font_size", 11)
		row.add_child(axis_label)

		var spinbox: SpinBox = SpinBox.new()
		spinbox.min_value = min_val
		spinbox.max_value = max_val
		spinbox.step = step_val
		spinbox.value = values[i]
		spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spinbox.value_changed.connect(_on_vector3_axis_changed.bind(property, i))
		row.add_child(spinbox)

func _on_float_changed(value: float, property: String) -> void:
	if not _viewmodel:
		return
	_viewmodel.set(property, value)

func _on_vector3_axis_changed(value: float, property: String, axis: int) -> void:
	if not _viewmodel:
		return
	var current: Vector3 = _viewmodel.get(property)
	current[axis] = value
	_viewmodel.set(property, current)
	_apply_viewmodel_positions()

func _apply_viewmodel_positions() -> void:
	if not _viewmodel:
		return
	_viewmodel._sword_pivot.position = _viewmodel.sword_idle_position
	_viewmodel._sword_pivot.rotation_degrees = _viewmodel.sword_idle_rotation
	_viewmodel._shield_pivot.position = _viewmodel.shield_idle_position
	_viewmodel._shield_pivot.rotation_degrees = _viewmodel.shield_idle_rotation

func _on_export_pressed() -> void:
	if not _viewmodel:
		return
	var data: Dictionary = {}
	var properties: Array[String] = [
		"sword_idle_position", "sword_idle_rotation", "sword_scale",
		"shield_idle_position", "shield_idle_rotation", "shield_scale",
		"bob_frequency", "bob_amplitude",
		"attack_windup_duration", "attack_swing_duration", "attack_recovery_duration",
		"shield_raise_duration", "shield_raised_position", "shield_raised_rotation",
		"death_drop_duration",
	]
	for prop: String in properties:
		var value: Variant = _viewmodel.get(prop)
		if value is Vector3:
			var v: Vector3 = value as Vector3
			data[prop] = {"x": snapped(v.x, 0.001), "y": snapped(v.y, 0.001), "z": snapped(v.z, 0.001)}
		elif value is float:
			data[prop] = snapped(value as float, 0.001)
	var json: String = JSON.stringify(data, "  ")
	DisplayServer.clipboard_set(json)
