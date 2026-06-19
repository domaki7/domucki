class_name AnimationComponent
extends Node

signal animation_finished(anim_name: StringName)

var animation_player: AnimationPlayer
var _current_animation: StringName = &""
var _looping: bool = false

func _ready() -> void:
	_find_animation_player()
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)

func play(animation_name: StringName, crossfade: float = 0.2, loop: bool = false) -> void:
	if not animation_player:
		return
	if animation_name == _current_animation:
		return
	_current_animation = animation_name
	_looping = loop
	animation_player.play(animation_name, -1, 1.0, false)

func is_playing(animation_name: StringName) -> bool:
	return animation_player.is_playing() and _current_animation == animation_name

func get_current_animation() -> StringName:
	return _current_animation

func _find_animation_player() -> void:
	var parent: Node = get_parent()
	if not parent:
		return
	for child: Node in parent.get_children():
		var found: AnimationPlayer = _search_for_animation_player(child)
		if found:
			animation_player = found
			return

func _search_for_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found: AnimationPlayer = _search_for_animation_player(child)
		if found:
			return found
	return null

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if _looping and anim_name == _current_animation:
		_current_animation = &""
		play(anim_name, 0.0, true)
		return
	animation_finished.emit(anim_name)
