extends Node3D

@onready var _player = $AnimationPlayer

func _ready() -> void:
	_player.play("demo_character_animation/Root_Run")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
