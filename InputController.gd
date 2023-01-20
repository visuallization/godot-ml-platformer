extends Node

export (NodePath) var player_path
onready var player = get_node(player_path)

func _physics_process(delta) -> void:
	var vertical: int = Input.get_axis("up", "down")
	var horizontal: int = Input.get_axis("right", "left")
	var jump: bool = Input.is_action_pressed("jump")
	player.set_forward_input(vertical)
	player.set_turn_input(horizontal)
	player.set_jump_input(jump)
