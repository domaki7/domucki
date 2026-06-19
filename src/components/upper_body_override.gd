class_name UpperBodyOverride
extends SkeletonModifier3D

var bone_poses: Dictionary = {}

func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if not skeleton:
		return
	for bone_idx: int in bone_poses:
		var data: Dictionary = bone_poses[bone_idx]
		if data.has("rotation"):
			skeleton.set_bone_pose_rotation(bone_idx, data["rotation"])
		if data.has("position"):
			skeleton.set_bone_pose_position(bone_idx, data["position"])
