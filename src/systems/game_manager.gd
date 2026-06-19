extends Node

enum GameState { PLAYING, PAUSED, LOADING, CUTSCENE }

signal game_state_changed(old_state: GameState, new_state: GameState)
signal player_registered(player_node: CharacterBody3D)

@export var starting_state: GameState = GameState.PLAYING

var current_state: GameState = GameState.PLAYING
var player: CharacterBody3D = null

func _ready() -> void:
	current_state = starting_state

func change_state(new_state: GameState) -> void:
	var old_state: GameState = current_state
	current_state = new_state
	game_state_changed.emit(old_state, new_state)

	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
		GameState.PLAYING:
			get_tree().paused = false

func register_player(player_node: CharacterBody3D) -> void:
	player = player_node
	player_registered.emit(player_node)
