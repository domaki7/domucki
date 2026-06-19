extends Node

const SAVE_DIR: String = "user://saves/"

@export var max_save_slots: int = 3

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_game(slot: int) -> void:
	var save_data: Dictionary = {}
	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("saveable")

	for node: Node in save_nodes:
		if node.has_method("save_data"):
			save_data[node.get_path()] = node.call("save_data")

	var file: FileAccess = FileAccess.open(SAVE_DIR + "save_%d.json" % slot, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))

func load_game(slot: int) -> void:
	var path: String = SAVE_DIR + "save_%d.json" % slot
	if not FileAccess.file_exists(path):
		return

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return

	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return

	var save_data: Dictionary = json.data
	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("saveable")

	for node: Node in save_nodes:
		var node_path: String = str(node.get_path())
		if save_data.has(node_path) and node.has_method("load_data"):
			node.call("load_data", save_data[node_path])

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "save_%d.json" % slot)
