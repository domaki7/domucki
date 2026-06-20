extends Control

var _stamina: StaminaComponent = null
var _camera: FirstPersonCamera = null
var _scroll: ScrollContainer
var _content: VBoxContainer
var _defaults: Dictionary = {}
var _float_spinboxes: Dictionary = {}
var _reset_buttons: Dictionary = {}
var _camera_defaults: Dictionary = {}
var _camera_spinboxes: Dictionary = {}
var _camera_reset_buttons: Dictionary = {}

func _ready() -> void:
	_scroll = ScrollContainer.new()
	_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_scroll)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_content)

func setup(stamina: StaminaComponent, camera: FirstPersonCamera = null) -> void:
	_stamina = stamina
	_camera = camera
	_build_controls()

func _build_controls() -> void:
	for child: Node in _content.get_children():
		child.queue_free()

	_defaults.clear()
	_float_spinboxes.clear()
	_reset_buttons.clear()

	_add_header("Stamina Pool")
	_add_float_control("max_stamina", 1.0, 500.0, 10.0)
	_add_float_control("regen_rate", 0.0, 100.0, 1.0)
	_add_float_control("regen_delay", 0.0, 5.0, 0.1)

	_add_header("Costs")
	_add_float_control("sprint_drain_rate", 0.0, 100.0, 1.0)
	_add_float_control("jump_cost", 0.0, 100.0, 1.0)
	_add_float_control("attack_cost", 0.0, 100.0, 1.0)
	_add_float_control("block_cost", 0.0, 100.0, 1.0)

	if _camera:
		_add_header("Sprint FOV")
		_add_camera_float_control("sprint_fov_increase", 0.0, 30.0, 1.0)
		_add_camera_float_control("fov_tween_duration", 0.01, 2.0, 0.01)

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
	var default_value: float = _stamina.get(property)
	_defaults[property] = default_value

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
	spinbox.value = default_value
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spinbox.value_changed.connect(_on_float_changed.bind(property))
	row.add_child(spinbox)

	_float_spinboxes[property] = spinbox

	var reset_btn: Button = Button.new()
	reset_btn.text = "↺"
	reset_btn.custom_minimum_size = Vector2(28.0, 0.0)
	reset_btn.modulate.a = 0.0
	reset_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reset_btn.pressed.connect(_on_float_reset.bind(property))
	row.add_child(reset_btn)

	_reset_buttons[property] = reset_btn

func _add_camera_float_control(property: String, min_val: float, max_val: float, step_val: float) -> void:
	var default_value: float = _camera.get(property)
	_camera_defaults[property] = default_value

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
	spinbox.value = default_value
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spinbox.value_changed.connect(_on_camera_float_changed.bind(property))
	row.add_child(spinbox)

	_camera_spinboxes[property] = spinbox

	var reset_btn: Button = Button.new()
	reset_btn.text = "↺"
	reset_btn.custom_minimum_size = Vector2(28.0, 0.0)
	reset_btn.modulate.a = 0.0
	reset_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reset_btn.pressed.connect(_on_camera_float_reset.bind(property))
	row.add_child(reset_btn)

	_camera_reset_buttons[property] = reset_btn

func _on_camera_float_changed(value: float, property: String) -> void:
	if not _camera:
		return
	_camera.set(property, value)
	if _camera_reset_buttons.has(property):
		var btn: Button = _camera_reset_buttons[property] as Button
		var changed: bool = not is_equal_approx(value, _camera_defaults[property] as float)
		btn.modulate.a = 1.0 if changed else 0.0
		btn.mouse_filter = Control.MOUSE_FILTER_STOP if changed else Control.MOUSE_FILTER_IGNORE

func _on_camera_float_reset(property: String) -> void:
	if not _camera:
		return
	var default_value: float = _camera_defaults[property] as float
	_camera.set(property, default_value)
	var spinbox: SpinBox = _camera_spinboxes[property] as SpinBox
	spinbox.set_value_no_signal(default_value)
	var btn: Button = _camera_reset_buttons[property] as Button
	btn.modulate.a = 0.0
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_float_changed(value: float, property: String) -> void:
	if not _stamina:
		return
	_stamina.set(property, value)
	if _reset_buttons.has(property):
		var btn: Button = _reset_buttons[property] as Button
		var changed: bool = not is_equal_approx(value, _defaults[property] as float)
		btn.modulate.a = 1.0 if changed else 0.0
		btn.mouse_filter = Control.MOUSE_FILTER_STOP if changed else Control.MOUSE_FILTER_IGNORE

func _on_float_reset(property: String) -> void:
	if not _stamina:
		return
	var default_value: float = _defaults[property] as float
	_stamina.set(property, default_value)
	var spinbox: SpinBox = _float_spinboxes[property] as SpinBox
	spinbox.set_value_no_signal(default_value)
	var btn: Button = _reset_buttons[property] as Button
	btn.modulate.a = 0.0
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_export_pressed() -> void:
	if not _stamina:
		return
	var data: Dictionary = {}
	var properties: Array[String] = [
		"max_stamina", "regen_rate", "regen_delay",
		"sprint_drain_rate", "jump_cost", "attack_cost", "block_cost",
	]
	for prop: String in properties:
		var value: Variant = _stamina.get(prop)
		if not _defaults.has(prop):
			continue
		var default_val: Variant = _defaults[prop]
		if value is float:
			if is_equal_approx(value as float, default_val as float):
				continue
			data[prop] = snapped(value as float, 0.001)
	if _camera:
		var camera_properties: Array[String] = [
			"sprint_fov_increase", "fov_tween_duration",
		]
		for prop: String in camera_properties:
			var value: Variant = _camera.get(prop)
			if not _camera_defaults.has(prop):
				continue
			var default_val: Variant = _camera_defaults[prop]
			if value is float:
				if is_equal_approx(value as float, default_val as float):
					continue
				data[prop] = snapped(value as float, 0.001)
	var json: String = JSON.stringify(data, "  ")
	DisplayServer.clipboard_set(json)
