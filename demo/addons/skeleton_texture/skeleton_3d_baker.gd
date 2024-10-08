@tool
extends Node
class_name Skeleton3DBaker

## Animation library containing all animations to bake.
@export var animations : AnimationLibrary
## Mesh instance to bake animations for.
@export var mesh_instance : MeshInstance3D
## Directory to place generated textures into.
@export_dir var output_dir : String

var tracked_outputs : Dictionary

## Validate the Node state before calling any further functions.
func _validate_state() -> bool:
	# Validate properties.
	if animations == null:
		push_error("Skeleton3DBaker: Missing AnimationLibrary reference.")
		return false

	if mesh_instance == null:
		push_error("Skeleton3DBaker: Missing MeshInstance3D reference.")
		return false

	if output_dir == "":
		push_error("Skeleton3DBaker: Missing output directory for baked textures.")
		return false

	# Fix broken cache.
	if tracked_outputs == null:
		tracked_outputs = {}

	# Validate mesh_instance.
	var skin = mesh_instance.skin
	var skeleton = mesh_instance.skeleton

	if mesh_instance.mesh == null:
		push_error("Skeleton3DBaker: Missing Mesh reference inside MeshInstance3D.")
		return false

	var mesh = mesh_instance.mesh as ArrayMesh

	if mesh == null: # Assume if mesh is not null and casted mesh is, then cast failed.
		push_error("Skeleton3DBaker: Not supported: only ArrayMesh instances are supported.")
		return false

	if mesh.get_surface_count() != 1:
		push_error("Skeleton3DBaker: Not supported: only meshes with 1 surface are supported.")
		return false

	if mesh.get_blend_shape_count() != 0:
		push_error("Skeleton3DBaker: Not supported: blend shapes are not supported.")
		return false

	var mesh_surface_idx = 0

	if mesh.surface_get_primitive_type(mesh_surface_idx) != Mesh.PrimitiveType.PRIMITIVE_TRIANGLES:
		push_error("Skeleton3DBaker: Not supported: only mesh surfaces from triangle primitives are supported.")
		return false

	var format = mesh.surface_get_format(mesh_surface_idx)

	if format & Mesh.ArrayFormat.ARRAY_FLAG_USE_8_BONE_WEIGHTS != 0:
		push_error("Skeleton3DBaker: Not supported: only mesh surfaces with up to 4 bone weights are supported.")
		return false

	if format & Mesh.ArrayFormat.ARRAY_FORMAT_BONES == 0:
		push_error("Skeleton3DBaker: mesh surface bones array is missing.")
		return false

	if format & Mesh.ArrayFormat.ARRAY_FORMAT_WEIGHTS == 0:
		push_error("Skeleton3DBaker: mesh surface weights array is missing.")
		return false

	if format & Mesh.ArrayFormat.ARRAY_FORMAT_NORMAL != 0:
		push_warning("Skeleton3DBaker: Not supported: mesh surface normals are not yet supported.")
		return false

	print("Skeleton3DBaker: validation passed.")
	return true

## Assuming the state has been pre-validated, validate a specific animation. [br]
## [param anim_name]: the name of the animation inside the AnimationLibrary [member animations] to validate.
func _validate_anim(anim_name : StringName) -> bool:
	return animations.has_animation(anim_name)

## Bake an animation into a texture and save it to [member output_dir]. [br]
## [param anim_name]: the name of the animation inside the AnimationLibrary [member animations] to bake.
func _generate_anim(anim_name : StringName) -> String:
	var width = 100
	var height = 100
	var texture = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)

	var animation : Animation = animations.get_animation(anim_name)
	print("Tracks: ", animation.get_track_count())

	var output_path = output_dir + "/" + anim_name + ".webp"
	#texture.save_webp(output_path, false, 1.0)

	#tracked_outputs[anim_name] = output_path
	return output_path
