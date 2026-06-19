class_name PlayerDeathState
extends PlayerState

@export var reload_delay: float = 1.0

func enter() -> void:
	player.stop_defend()
	hitbox.deactivate()
	animation.play(&"Death_A", 0.1)
	animation.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if animation.animation_finished.is_connected(_on_animation_finished):
		animation.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)
	movement.apply_friction(delta)
	movement.move()

func _on_animation_finished(_anim_name: StringName) -> void:
	get_tree().create_timer(reload_delay).timeout.connect(_on_reload_timer_timeout)

func _on_reload_timer_timeout() -> void:
	SceneManager.change_scene(get_tree().current_scene.scene_file_path)
