extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is Skeleton3DBaker

func _parse_category(object: Object, category: String) -> void:
	if category == "skeleton_3d_baker.gd":
		var force_regen_button = Button.new()
		force_regen_button.text = "Force Bake"
		force_regen_button.pressed.connect(_on_force_regen_button_pressed.bind(object as Skeleton3DBaker))
		add_custom_control(force_regen_button)

func _on_force_regen_button_pressed(object : Skeleton3DBaker) -> void:
	var editor = EditorPlugin.new()
	var editor_fs = editor.get_editor_interface().get_resource_filesystem()

	var anims = object.animations.get_animation_list()
	var outputs = anims.map(object._generateAnim)

	editor_fs.scan()
	editor.free()
