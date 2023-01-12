extends Node

export (NodePath) var player_path
onready var player = get_node(player_path)

func _physics_process(delta) -> void:
	var jump: bool = Input.is_key_pressed(KEY_SPACE)
	player.set_jump_input(jump)