extends Node

export (NodePath) var player_path
onready var player = get_node(player_path)

func _physics_process(delta) -> void:
	var vertical: int = Input.get_axis("ui_up", "ui_down")
	var horizontal: int = Input.get_axis("ui_right", "ui_left")
	var jump: bool = Input.is_key_pressed(KEY_SPACE)
	player.set_forward_input(vertical)
	player.set_turn_input(horizontal)
	player.set_jump_input(jump)