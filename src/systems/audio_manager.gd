extends Node

@export var sfx_pool_size: int = 16
@export var music_crossfade_duration: float = 1.0

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_3d_players: Array[AudioStreamPlayer3D] = []
var _music_player: AudioStreamPlayer = null
var _sfx_index: int = 0
var _sfx_3d_index: int = 0

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	for i: int in sfx_pool_size:
		var player_2d: AudioStreamPlayer = AudioStreamPlayer.new()
		player_2d.bus = "SFX"
		add_child(player_2d)
		_sfx_players.append(player_2d)

		var player_3d: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		player_3d.bus = "SFX"
		add_child(player_3d)
		_sfx_3d_players.append(player_3d)

func play_sfx(stream: AudioStream) -> void:
	var player: AudioStreamPlayer = _sfx_players[_sfx_index]
	player.stream = stream
	player.play()
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()

func play_sfx_3d(stream: AudioStream, position: Vector3) -> void:
	var player: AudioStreamPlayer3D = _sfx_3d_players[_sfx_3d_index]
	player.stream = stream
	player.global_position = position
	player.play()
	_sfx_3d_index = (_sfx_3d_index + 1) % _sfx_3d_players.size()

func play_music(stream: AudioStream) -> void:
	_music_player.stream = stream
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()
