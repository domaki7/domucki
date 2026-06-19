class_name StateMachine
extends Node

signal state_changed(old_state: State, new_state: State)

@export var initial_state: State

var current_state: State = null
var _states: Dictionary = {}

func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			_states[child.name] = child
			child.transition_requested.connect(_on_transition_requested)

	if initial_state:
		current_state = initial_state
		current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.process_state(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process_state(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func transition_to(state_name: StringName) -> void:
	if not _states.has(state_name):
		push_error("State '%s' not found in StateMachine." % state_name)
		return

	var new_state: State = _states[state_name]
	if new_state == current_state:
		return

	var old_state: State = current_state
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
	state_changed.emit(old_state, new_state)

func _on_transition_requested(_from: State, to: StringName) -> void:
	transition_to(to)
