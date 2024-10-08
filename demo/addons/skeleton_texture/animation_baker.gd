extends Object
class_name AnimationBaker

## Bake animation into a texture. [br]
## [param animation]: animation to bake. [br]
## [param mesh_instance]: mesh instance for which the animation is meant. [br]
## [param target_fps]: how many frames per second should be baked.
static func bake_animation(animation : Animation, mesh_instance : MeshInstance3D, target_fps : float) -> Image:
	var animation_frames = floor(animation.length * target_fps) # Total number of frames.

	var mesh : ArrayMesh = mesh_instance.mesh as ArrayMesh
	var mesh_surface = mesh.surface_get_arrays(0)
	var mesh_vertices : PackedVector3Array = mesh_surface[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var mesh_bones : PackedInt32Array = mesh_surface[Mesh.ARRAY_BONES] as PackedInt32Array
	var mesh_weights : PackedFloat32Array = mesh_surface[Mesh.ARRAY_WEIGHTS] as PackedFloat32Array
	var vertex_count : int = mesh_vertices.size()

	# Step 1. Get all skin bind poses for this frame.
	# Example: Skeleton3D::_notification in https://github.com/godotengine/godot/blob/master/scene/3d/skeleton_3d.cpp#L409
	# All bind poses remain the same regardless of animation.
	var skeleton : Skeleton3D = mesh_instance.get_node(mesh_instance.skeleton) as Skeleton3D
	var skeleton_bone_count = skeleton.get_bone_count()

	var skin : Skin = mesh_instance.skin
	var skin_bind_count = skin.get_bind_count()

	var skin_bone_indices_ptrs : Array[int] = []
	skin_bone_indices_ptrs.resize(skin_bind_count)

	for j in range(skin_bind_count):
		var bind_name = skin.get_bind_name(j)
		var bind_bone = skin.get_bind_bone(j)

		if bind_name != StringName():
			var found = false

			for b in range(skeleton_bone_count):
				if skeleton.get_bone_name(b) == bind_name:
					skin_bone_indices_ptrs[j] = b
					found = true
					break

			if not found:
				push_error("AnimationBaker: Skin bind #", j, " contains named bind '", bind_name, "' but Skeleton3D has no bone by that name.")
				skin_bone_indices_ptrs[j] = 0
		elif bind_bone >= 0:
			if bind_bone >= skeleton_bone_count:
				push_error("AnimationBaker: Skin bind #", j, " contains bone index bind ", bind_bone, ", which is greater than the skeleton bone count ", skeleton_bone_count, ".")
				skin_bone_indices_ptrs[j] = 0
			else:
				skin_bone_indices_ptrs[j] = bind_bone
		else:
			push_error("AnimationBaker: Skin bind #", j, " does not contain a name nor a bone index.")
			skin_bone_indices_ptrs[j] = 0

	var vertex_offsets : PackedVector3Array = PackedVector3Array()
	vertex_offsets.resize(vertex_count)
	var vertex_max_magnitude : float = 1.0

	# TODO: convert this to the closest power of 2.
	var width = vertex_count
	var height = animation_frames # TODO: expand this to multiple animations per texture.
	var texture : Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)

	for i in range(animation_frames):
		var animation_time = i / target_fps
		# Step 2. Get all global bone poses for this frame.
		# Example: Skeleton3D::force_update_bone_children_transforms in https://github.com/godotengine/godot/blob/master/scene/3d/skeleton_3d.cpp#L936

		# Step 3. Map XYZ to RGB.
		# Example: https://www.youtube.com/watch?v=rXqKu9uC0f4
		for v in range(vertex_count):
			var magnitude = vertex_offsets[v].length()
			var vertex = (vertex_offsets[v].normalized() + Vector3(1.0, 1.0, 1.0)) * 0.5 # Map v to [-1;1] to [0;1].
			# TODO: probably faster to construct a BMP and pass it to the image.
			texture.set_pixel(v, i, Color(vertex.x, vertex.y, vertex.z, magnitude / vertex_max_magnitude))

	return texture
