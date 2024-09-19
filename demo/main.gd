extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_Sprite2D_position_changed(node, new_pos):
	print("The position of " + node.get_class() + " is now " + str(new_pos))
