extends Node

signal scene_load_started(scene_path: String)
signal scene_load_progress(progress: float)
signal scene_load_completed(scene_path: String)

@export var loading_screen_scene: PackedScene
@export var fade_duration: float = 0.5

var _loading_scene_path: String = ""

func change_scene(scene_path: String) -> void:
	scene_load_started.emit(scene_path)
	_loading_scene_path = scene_path
	ResourceLoader.load_threaded_request(scene_path)
	set_process(true)

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	if _loading_scene_path.is_empty():
		return

	var progress: Array = []
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_loading_scene_path, progress)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			scene_load_progress.emit(progress[0])
		ResourceLoader.THREAD_LOAD_LOADED:
			var scene: PackedScene = ResourceLoader.load_threaded_get(_loading_scene_path) as PackedScene
			scene_load_completed.emit(_loading_scene_path)
			_loading_scene_path = ""
			set_process(false)
			get_tree().change_scene_to_packed(scene)
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: %s" % _loading_scene_path)
			_loading_scene_path = ""
			set_process(false)
