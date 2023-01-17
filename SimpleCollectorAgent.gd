extends Node

export (NodePath) var player_path
onready var player = get_node(player_path)

var _heuristic := "player"
var done := false

func set_heuristic(heuristic):
	# sets the heuristic from "human" or "model"
	self._heuristic = heuristic

func get_done():
	return done
