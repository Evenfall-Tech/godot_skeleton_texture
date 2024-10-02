@tool
extends Node
class_name Skeleton3DBaker

@export var animations : AnimationLibrary
@export_dir var output_dir : String

var tracked_outputs = {}

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func _generateAnim(anim_name : StringName) -> String:
	var width = 100
	var height = 100
	var texture = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)

	var animation : Animation = animations.get_animation(anim_name)
	print(animation.get_track_count())

	var output_path = output_dir + "/" + anim_name + ".webp"
	#texture.save_webp(output_path, false, 1.0)

	if tracked_outputs == null:
		tracked_outputs = {}

	#tracked_outputs[anim_name] = output_path
	return output_path
