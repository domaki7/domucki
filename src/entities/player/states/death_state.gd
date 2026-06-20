class_name PlayerDeathState
extends PlayerState

@export var reload_delay: float = 1.0

func enter() -> void:
	viewmodel.lower_shield()
	hitbox.deactivate()
	viewmodel.play_death()
	viewmodel.death_finished.connect(_on_death_finished)

func exit() -> void:
	if viewmodel.death_finished.is_connected(_on_death_finished):
		viewmodel.death_finished.disconnect(_on_death_finished)

func physics_process_state(delta: float) -> void:
	movement.apply_gravity(delta)
	movement.apply_friction(delta)
	movement.move()

func _on_death_finished() -> void:
	get_tree().create_timer(reload_delay).timeout.connect(_on_reload_timer_timeout)

func _on_reload_timer_timeout() -> void:
	SceneManager.change_scene(get_tree().current_scene.scene_file_path)
