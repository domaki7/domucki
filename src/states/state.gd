class_name State
extends Node

signal transition_requested(from: State, to: StringName)

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_state(_delta: float) -> void:
	pass

func physics_process_state(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
