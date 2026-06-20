extends Control

const HITBOX_COLOR: Color = Color(1.0, 0.0, 0.0, 0.3)
const HURTBOX_COLOR: Color = Color(0.0, 0.5, 1.0, 0.3)
const OVERLAY_NAME: String = "DebugOverlay"

var _player: Player = null
var _scroll: ScrollContainer
var _content: VBoxContainer
var _defaults: Dictionary = {}
var _float_spinboxes: Dictionary = {}
var _vector3_spinboxes: Dictionary = {}
var _reset_buttons: Dictionary = {}
var _show_player_hitbox: bool = false
var _show_player_hurtbox: bool = false
var _show_enemy_hitbox: bool = false
var _show_enemy_hurtbox: bool = false
var _enemy_invulnerable: bool = false
var _tracked_enemy_count: int = 0

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

func setup(player: Player) -> void:
	_player = player
	_build_controls()

func _process(_delta: float) -> void:
	if not _player:
		return
	var current_count: int = get_tree().get_nodes_in_group("enemies").size()
	if current_count != _tracked_enemy_count:
		_tracked_enemy_count = current_count
		_apply_current_enemy_values()

func _exit_tree() -> void:
	_remove_all_overlays()

func _build_controls() -> void:
	for child: Node in _content.get_children():
		child.queue_free()
	_defaults.clear()
	_float_spinboxes.clear()
	_vector3_spinboxes.clear()
	_reset_buttons.clear()

	var p_hitbox_cs: CollisionShape3D = _player.hitbox_component.get_collision_shape()
	var p_hitbox_sphere: SphereShape3D = p_hitbox_cs.shape as SphereShape3D

	_add_header("Player")
	_add_checkbox_control("Invulnerable", _on_player_invulnerable_toggled)

	_add_header("Player Hitbox")
	_add_checkbox_control("Show Hitbox", _on_player_hitbox_visibility_toggled)
	_add_float_control("p_hitbox_radius", "radius", p_hitbox_sphere.radius, 0.01, 3.0, 0.01)
	_add_vector3_control("p_hitbox_position", "position", p_hitbox_cs.position, -3.0, 3.0, 0.01)

	var p_hurtbox_cs: CollisionShape3D = _player.hurtbox_component.get_collision_shape()
	var p_hurtbox_capsule: CapsuleShape3D = p_hurtbox_cs.shape as CapsuleShape3D

	_add_header("Player Hurtbox")
	_add_checkbox_control("Show Hurtbox", _on_player_hurtbox_visibility_toggled)
	_add_float_control("p_hurtbox_radius", "radius", p_hurtbox_capsule.radius, 0.01, 3.0, 0.01)
	_add_float_control("p_hurtbox_height", "height", p_hurtbox_capsule.height, 0.01, 5.0, 0.01)
	_add_vector3_control("p_hurtbox_position", "position", p_hurtbox_cs.position, -3.0, 3.0, 0.01)

	var e_hitbox: Dictionary = _get_first_enemy_hitbox_defaults()

	_add_header("Enemy (All)")
	_add_checkbox_control("Invulnerable", _on_enemy_invulnerable_toggled)

	_add_header("Enemy Hitbox (All)")
	_add_checkbox_control("Show Hitbox", _on_enemy_hitbox_visibility_toggled)
	_add_float_control("e_hitbox_radius", "radius", e_hitbox.get("radius", 0.6) as float, 0.01, 3.0, 0.01)
	_add_vector3_control("e_hitbox_position", "position", e_hitbox.get("position", Vector3(0.0, 0.5, -0.8)) as Vector3, -3.0, 3.0, 0.01)

	var e_hurtbox: Dictionary = _get_first_enemy_hurtbox_defaults()

	_add_header("Enemy Hurtbox (All)")
	_add_checkbox_control("Show Hurtbox", _on_enemy_hurtbox_visibility_toggled)
	_add_float_control("e_hurtbox_radius", "radius", e_hurtbox.get("radius", 0.35) as float, 0.01, 3.0, 0.01)
	_add_float_control("e_hurtbox_height", "height", e_hurtbox.get("height", 1.0) as float, 0.01, 5.0, 0.01)
	_add_vector3_control("e_hurtbox_position", "position", e_hurtbox.get("position", Vector3(0.0, 0.5, 0.0)) as Vector3, -3.0, 3.0, 0.01)

	var sep: HSeparator = HSeparator.new()
	_content.add_child(sep)

	var export_button: Button = Button.new()
	export_button.text = "Copy Values to Clipboard"
	export_button.pressed.connect(_on_export_pressed)
	_content.add_child(export_button)

func _get_first_enemy_hitbox_defaults() -> Dictionary:
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		var hitbox: HitboxComponent = enemy.get_node_or_null("HitboxComponent") as HitboxComponent
		if hitbox:
			var cs: CollisionShape3D = hitbox.get_collision_shape()
			if cs and cs.shape is SphereShape3D:
				return {"radius": (cs.shape as SphereShape3D).radius, "position": cs.position}
	return {"radius": 0.6, "position": Vector3(0.0, 0.5, -0.8)}

func _get_first_enemy_hurtbox_defaults() -> Dictionary:
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		var hurtbox: HurtboxComponent = enemy.get_node_or_null("HurtboxComponent") as HurtboxComponent
		if hurtbox:
			var cs: CollisionShape3D = hurtbox.get_collision_shape()
			if cs and cs.shape is CapsuleShape3D:
				var capsule: CapsuleShape3D = cs.shape as CapsuleShape3D
				return {"radius": capsule.radius, "height": capsule.height, "position": cs.position}
	return {"radius": 0.35, "height": 1.0, "position": Vector3(0.0, 0.5, 0.0)}

func _add_header(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	_content.add_child(label)

	var sep: HSeparator = HSeparator.new()
	_content.add_child(sep)

func _add_checkbox_control(label_text: String, callback: Callable) -> CheckBox:
	var row: HBoxContainer = HBoxContainer.new()
	_content.add_child(row)

	var checkbox: CheckBox = CheckBox.new()
	checkbox.text = label_text
	checkbox.add_theme_font_size_override("font_size", 12)
	checkbox.toggled.connect(callback)
	row.add_child(checkbox)

	return checkbox

func _add_float_control(key: String, display_name: String, initial_value: float, min_val: float, max_val: float, step_val: float) -> void:
	_defaults[key] = initial_value

	var row: HBoxContainer = HBoxContainer.new()
	_content.add_child(row)

	var label: Label = Label.new()
	label.text = display_name
	label.custom_minimum_size.x = 140.0
	label.add_theme_font_size_override("font_size", 12)
	row.add_child(label)

	var spinbox: SpinBox = SpinBox.new()
	spinbox.min_value = min_val
	spinbox.max_value = max_val
	spinbox.step = step_val
	spinbox.value = initial_value
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spinbox.value_changed.connect(_on_float_changed.bind(key))
	row.add_child(spinbox)

	_float_spinboxes[key] = spinbox

	var reset_btn: Button = Button.new()
	reset_btn.text = "↺"
	reset_btn.custom_minimum_size = Vector2(28.0, 0.0)
	reset_btn.modulate.a = 0.0
	reset_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reset_btn.pressed.connect(_on_float_reset.bind(key))
	row.add_child(reset_btn)

	_reset_buttons[key] = reset_btn

func _add_vector3_control(key: String, display_name: String, initial_value: Vector3, min_val: float, max_val: float, step_val: float) -> void:
	_defaults[key] = initial_value

	var label: Label = Label.new()
	label.text = display_name
	label.add_theme_font_size_override("font_size", 12)
	_content.add_child(label)

	var row: HBoxContainer = HBoxContainer.new()
	_content.add_child(row)

	var axes: Array[String] = ["x", "y", "z"]
	var values: Array[float] = [initial_value.x, initial_value.y, initial_value.z]
	var spinboxes: Array[SpinBox] = []
	var reset_btns: Array[Button] = []

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
		spinbox.value_changed.connect(_on_vector3_axis_changed.bind(key, i))
		row.add_child(spinbox)
		spinboxes.append(spinbox)

		var reset_btn: Button = Button.new()
		reset_btn.text = "↺"
		reset_btn.custom_minimum_size = Vector2(28.0, 0.0)
		reset_btn.modulate.a = 0.0
		reset_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		reset_btn.pressed.connect(_on_vector3_axis_reset.bind(key, i))
		row.add_child(reset_btn)
		reset_btns.append(reset_btn)

	_vector3_spinboxes[key] = spinboxes
	_reset_buttons[key] = reset_btns

func _apply_float_value(key: String, value: float) -> void:
	match key:
		"p_hitbox_radius":
			(_player.hitbox_component.get_collision_shape().shape as SphereShape3D).radius = value
			_update_overlay(_player.hitbox_component.get_collision_shape())
		"p_hurtbox_radius":
			(_player.hurtbox_component.get_collision_shape().shape as CapsuleShape3D).radius = value
			_update_overlay(_player.hurtbox_component.get_collision_shape())
		"p_hurtbox_height":
			(_player.hurtbox_component.get_collision_shape().shape as CapsuleShape3D).height = value
			_update_overlay(_player.hurtbox_component.get_collision_shape())
		"e_hitbox_radius":
			for enemy: Node in _get_enemies():
				var hitbox: HitboxComponent = enemy.get_node_or_null("HitboxComponent") as HitboxComponent
				if hitbox:
					(hitbox.get_collision_shape().shape as SphereShape3D).radius = value
					_update_overlay(hitbox.get_collision_shape())
		"e_hurtbox_radius":
			for enemy: Node in _get_enemies():
				var hurtbox: HurtboxComponent = enemy.get_node_or_null("HurtboxComponent") as HurtboxComponent
				if hurtbox:
					(hurtbox.get_collision_shape().shape as CapsuleShape3D).radius = value
					_update_overlay(hurtbox.get_collision_shape())
		"e_hurtbox_height":
			for enemy: Node in _get_enemies():
				var hurtbox: HurtboxComponent = enemy.get_node_or_null("HurtboxComponent") as HurtboxComponent
				if hurtbox:
					(hurtbox.get_collision_shape().shape as CapsuleShape3D).height = value
					_update_overlay(hurtbox.get_collision_shape())

func _apply_vector3_axis(key: String, axis: int, value: float) -> void:
	match key:
		"p_hitbox_position":
			var cs: CollisionShape3D = _player.hitbox_component.get_collision_shape()
			var pos: Vector3 = cs.position
			pos[axis] = value
			cs.position = pos
		"p_hurtbox_position":
			var cs: CollisionShape3D = _player.hurtbox_component.get_collision_shape()
			var pos: Vector3 = cs.position
			pos[axis] = value
			cs.position = pos
		"e_hitbox_position":
			for enemy: Node in _get_enemies():
				var hitbox: HitboxComponent = enemy.get_node_or_null("HitboxComponent") as HitboxComponent
				if hitbox:
					var cs: CollisionShape3D = hitbox.get_collision_shape()
					var pos: Vector3 = cs.position
					pos[axis] = value
					cs.position = pos
		"e_hurtbox_position":
			for enemy: Node in _get_enemies():
				var hurtbox: HurtboxComponent = enemy.get_node_or_null("HurtboxComponent") as HurtboxComponent
				if hurtbox:
					var cs: CollisionShape3D = hurtbox.get_collision_shape()
					var pos: Vector3 = cs.position
					pos[axis] = value
					cs.position = pos

func _create_overlay_material(color: Color) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat

func _add_sphere_overlay(collision_shape: CollisionShape3D, color: Color) -> void:
	_remove_overlay(collision_shape)
	var sphere_shape: SphereShape3D = collision_shape.shape as SphereShape3D
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = OVERLAY_NAME
	var sphere_mesh: SphereMesh = SphereMesh.new()
	sphere_mesh.radius = sphere_shape.radius
	sphere_mesh.height = sphere_shape.radius * 2.0
	mesh_instance.mesh = sphere_mesh
	mesh_instance.material_override = _create_overlay_material(color)
	collision_shape.add_child(mesh_instance)

func _add_capsule_overlay(collision_shape: CollisionShape3D, color: Color) -> void:
	_remove_overlay(collision_shape)
	var capsule_shape: CapsuleShape3D = collision_shape.shape as CapsuleShape3D
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = OVERLAY_NAME
	var capsule_mesh: CapsuleMesh = CapsuleMesh.new()
	capsule_mesh.radius = capsule_shape.radius
	capsule_mesh.height = capsule_shape.height
	mesh_instance.mesh = capsule_mesh
	mesh_instance.material_override = _create_overlay_material(color)
	collision_shape.add_child(mesh_instance)

func _remove_overlay(collision_shape: CollisionShape3D) -> void:
	var overlay: Node = collision_shape.get_node_or_null(OVERLAY_NAME)
	if overlay:
		collision_shape.remove_child(overlay)
		overlay.queue_free()

func _update_overlay(collision_shape: CollisionShape3D) -> void:
	var overlay: MeshInstance3D = collision_shape.get_node_or_null(OVERLAY_NAME) as MeshInstance3D
	if not overlay:
		return
	if collision_shape.shape is SphereShape3D:
		var sphere: SphereShape3D = collision_shape.shape as SphereShape3D
		var mesh: SphereMesh = overlay.mesh as SphereMesh
		mesh.radius = sphere.radius
		mesh.height = sphere.radius * 2.0
	elif collision_shape.shape is CapsuleShape3D:
		var capsule: CapsuleShape3D = collision_shape.shape as CapsuleShape3D
		var mesh: CapsuleMesh = overlay.mesh as CapsuleMesh
		mesh.radius = capsule.radius
		mesh.height = capsule.height

func _get_enemies() -> Array[Node]:
	return get_tree().get_nodes_in_group("enemies")

func _apply_current_enemy_values() -> void:
	for enemy: Node in _get_enemies():
		if not is_instance_valid(enemy):
			continue
		var health: HealthComponent = enemy.get_node_or_null("HealthComponent") as HealthComponent
		if health:
			health.is_invulnerable = _enemy_invulnerable
		var hitbox: HitboxComponent = enemy.get_node_or_null("HitboxComponent") as HitboxComponent
		if hitbox:
			var cs: CollisionShape3D = hitbox.get_collision_shape()
			if cs and cs.shape is SphereShape3D:
				(cs.shape as SphereShape3D).radius = (_float_spinboxes["e_hitbox_radius"] as SpinBox).value
				var spinboxes: Array = _vector3_spinboxes["e_hitbox_position"] as Array
				cs.position = Vector3(
					(spinboxes[0] as SpinBox).value,
					(spinboxes[1] as SpinBox).value,
					(spinboxes[2] as SpinBox).value
				)
			if _show_enemy_hitbox:
				_add_sphere_overlay(cs, HITBOX_COLOR)
		var hurtbox: HurtboxComponent = enemy.get_node_or_null("HurtboxComponent") as HurtboxComponent
		if hurtbox:
			var cs: CollisionShape3D = hurtbox.get_collision_shape()
			if cs and cs.shape is CapsuleShape3D:
				var capsule: CapsuleShape3D = cs.shape as CapsuleShape3D
				capsule.radius = (_float_spinboxes["e_hurtbox_radius"] as SpinBox).value
				capsule.height = (_float_spinboxes["e_hurtbox_height"] as SpinBox).value
				var spinboxes: Array = _vector3_spinboxes["e_hurtbox_position"] as Array
				cs.position = Vector3(
					(spinboxes[0] as SpinBox).value,
					(spinboxes[1] as SpinBox).value,
					(spinboxes[2] as SpinBox).value
				)
			if _show_enemy_hurtbox:
				_add_capsule_overlay(cs, HURTBOX_COLOR)

func _remove_all_overlays() -> void:
	if is_instance_valid(_player):
		_remove_overlay(_player.hitbox_component.get_collision_shape())
		_remove_overlay(_player.hurtbox_component.get_collision_shape())
	for enemy: Node in _get_enemies():
		if not is_instance_valid(enemy):
			continue
		var hitbox: HitboxComponent = enemy.get_node_or_null("HitboxComponent") as HitboxComponent
		if hitbox:
			_remove_overlay(hitbox.get_collision_shape())
		var hurtbox: HurtboxComponent = enemy.get_node_or_null("HurtboxComponent") as HurtboxComponent
		if hurtbox:
			_remove_overlay(hurtbox.get_collision_shape())

func _on_float_changed(value: float, key: String) -> void:
	if not _player:
		return
	_apply_float_value(key, value)
	if _reset_buttons.has(key):
		var btn: Button = _reset_buttons[key] as Button
		var changed: bool = not is_equal_approx(value, _defaults[key] as float)
		btn.modulate.a = 1.0 if changed else 0.0
		btn.mouse_filter = Control.MOUSE_FILTER_STOP if changed else Control.MOUSE_FILTER_IGNORE

func _on_float_reset(key: String) -> void:
	if not _player:
		return
	var default_value: float = _defaults[key] as float
	_apply_float_value(key, default_value)
	var spinbox: SpinBox = _float_spinboxes[key] as SpinBox
	spinbox.set_value_no_signal(default_value)
	var btn: Button = _reset_buttons[key] as Button
	btn.modulate.a = 0.0
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_vector3_axis_changed(value: float, key: String, axis: int) -> void:
	if not _player:
		return
	_apply_vector3_axis(key, axis, value)
	if _reset_buttons.has(key):
		var btns: Array = _reset_buttons[key] as Array
		var default_val: Vector3 = _defaults[key] as Vector3
		var changed: bool = not is_equal_approx(value, default_val[axis])
		btns[axis].modulate.a = 1.0 if changed else 0.0
		btns[axis].mouse_filter = Control.MOUSE_FILTER_STOP if changed else Control.MOUSE_FILTER_IGNORE

func _on_vector3_axis_reset(key: String, axis: int) -> void:
	if not _player:
		return
	var default_value: Vector3 = _defaults[key] as Vector3
	_apply_vector3_axis(key, axis, default_value[axis])
	var spinboxes: Array = _vector3_spinboxes[key] as Array
	(spinboxes[axis] as SpinBox).set_value_no_signal(default_value[axis])
	var btns: Array = _reset_buttons[key] as Array
	(btns[axis] as Button).modulate.a = 0.0
	(btns[axis] as Button).mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_player_invulnerable_toggled(enabled: bool) -> void:
	_player.health_component.is_invulnerable = enabled

func _on_enemy_invulnerable_toggled(enabled: bool) -> void:
	_enemy_invulnerable = enabled
	for enemy: Node in _get_enemies():
		var health: HealthComponent = enemy.get_node_or_null("HealthComponent") as HealthComponent
		if health:
			health.is_invulnerable = enabled

func _on_player_hitbox_visibility_toggled(enabled: bool) -> void:
	_show_player_hitbox = enabled
	var cs: CollisionShape3D = _player.hitbox_component.get_collision_shape()
	if enabled:
		_add_sphere_overlay(cs, HITBOX_COLOR)
	else:
		_remove_overlay(cs)

func _on_player_hurtbox_visibility_toggled(enabled: bool) -> void:
	_show_player_hurtbox = enabled
	var cs: CollisionShape3D = _player.hurtbox_component.get_collision_shape()
	if enabled:
		_add_capsule_overlay(cs, HURTBOX_COLOR)
	else:
		_remove_overlay(cs)

func _on_enemy_hitbox_visibility_toggled(enabled: bool) -> void:
	_show_enemy_hitbox = enabled
	for enemy: Node in _get_enemies():
		var hitbox: HitboxComponent = enemy.get_node_or_null("HitboxComponent") as HitboxComponent
		if hitbox:
			var cs: CollisionShape3D = hitbox.get_collision_shape()
			if enabled:
				_add_sphere_overlay(cs, HITBOX_COLOR)
			else:
				_remove_overlay(cs)

func _on_enemy_hurtbox_visibility_toggled(enabled: bool) -> void:
	_show_enemy_hurtbox = enabled
	for enemy: Node in _get_enemies():
		var hurtbox: HurtboxComponent = enemy.get_node_or_null("HurtboxComponent") as HurtboxComponent
		if hurtbox:
			var cs: CollisionShape3D = hurtbox.get_collision_shape()
			if enabled:
				_add_capsule_overlay(cs, HURTBOX_COLOR)
			else:
				_remove_overlay(cs)

func _on_export_pressed() -> void:
	var data: Dictionary = {}
	for key: String in _defaults:
		var default_val: Variant = _defaults[key]
		if _float_spinboxes.has(key):
			var current: float = (_float_spinboxes[key] as SpinBox).value
			if is_equal_approx(current, default_val as float):
				continue
			data[key] = snapped(current, 0.001)
		elif _vector3_spinboxes.has(key):
			var spinboxes: Array = _vector3_spinboxes[key] as Array
			var current: Vector3 = Vector3(
				(spinboxes[0] as SpinBox).value,
				(spinboxes[1] as SpinBox).value,
				(spinboxes[2] as SpinBox).value
			)
			var d: Vector3 = default_val as Vector3
			if current.is_equal_approx(d):
				continue
			data[key] = {"x": snapped(current.x, 0.001), "y": snapped(current.y, 0.001), "z": snapped(current.z, 0.001)}
	var json: String = JSON.stringify(data, "  ")
	DisplayServer.clipboard_set(json)
