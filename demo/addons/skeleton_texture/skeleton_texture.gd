@tool
extends EditorPlugin

var plugin : EditorInspectorPlugin

func _enter_tree() -> void:
	add_custom_type("Skeleton3DBaker", "Node", preload("skeleton_3d_baker.gd"), null)

	plugin = preload("res://addons/skeleton_texture/skeleton_3d_baker_plugin.gd").new()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	if is_instance_valid(plugin):
		remove_inspector_plugin(plugin)
		plugin = null

	remove_custom_type("Skeleton3DBaker")
