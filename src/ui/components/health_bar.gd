class_name HealthBar
extends PanelContainer

@export_group("Appearance")
@export var bar_fill_color: Color = Color(0.8, 0.2, 0.2, 1.0)
@export var bar_background_color: Color = Color(0.15, 0.15, 0.15, 1.0)
@export var bar_min_size: Vector2 = Vector2(200.0, 24.0)
@export var icon_texture: Texture2D
@export var show_label: bool = true

@export_group("Animation")
@export var tween_duration: float = 0.3

@onready var _bar: ProgressBar = $MarginContainer/HBoxContainer/BarContainer/Bar
@onready var _label: Label = $MarginContainer/HBoxContainer/BarContainer/Label
@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/Icon

var _tween: Tween = null

func _ready() -> void:
	_apply_styles()
	if icon_texture:
		_icon.texture = icon_texture
	else:
		_icon.visible = false
	_label.visible = show_label

func update_health(current: float, maximum: float) -> void:
	_bar.max_value = maximum
	_animate_bar(current)
	_update_label(current, maximum)

func _animate_bar(target_value: float) -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_bar, "value", target_value, tween_duration)

func _update_label(current: float, maximum: float) -> void:
	_label.text = "%d / %d" % [roundi(current), roundi(maximum)]

func _apply_styles() -> void:
	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	fill_style.bg_color = bar_fill_color
	fill_style.corner_radius_top_left = 3
	fill_style.corner_radius_top_right = 3
	fill_style.corner_radius_bottom_left = 3
	fill_style.corner_radius_bottom_right = 3
	_bar.add_theme_stylebox_override("fill", fill_style)

	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = bar_background_color
	bg_style.corner_radius_top_left = 3
	bg_style.corner_radius_top_right = 3
	bg_style.corner_radius_bottom_left = 3
	bg_style.corner_radius_bottom_right = 3
	_bar.add_theme_stylebox_override("background", bg_style)
