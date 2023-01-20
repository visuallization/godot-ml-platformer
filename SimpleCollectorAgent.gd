extends Node

export (PackedScene) var platform_scene
export (PackedScene) var player_scene

onready var player = get_node("../Player")
onready var platform = get_node("../CoinPlatform")

var player_start_position: Vector3
var platform_start_position: Vector3

var rng

var _heuristic := "player"
var done := false

var move_action
var turn_action
var jump_action

func _ready():
	print("ready")

	rng = RandomNumberGenerator.new()
	rng.randomize()

	player_start_position = player.translation
	platform_start_position = platform.translation
	
func on_pickup_coin():
	print("pickup")

	done = true
	reset()

func reset():
	print("reset")

	player.queue_free()
	player = player_scene.instance()
	player.translation = player_start_position
	add_child(player)

	platform.queue_free()
	platform = platform_scene.instance()
	platform.translation = Vector3(rng.randi_range(-10, 10), platform_start_position.y, rng.randi_range(-10, 10))
	platform.connect("coin_collected", self, "on_pickup_coin")
	add_child(platform)

func set_heuristic(heuristic):
	# sets the heuristic from "human" or "model"
	self._heuristic = heuristic

func get_obs():
	# The observation of the agent, think of what is the key information that is needed to perform the task, try to have things in coordinates that a relative to the play
	# return a dictionary with the "obs" as a key, you can have several keys
	pass

func get_obs_size():
	return len(get_obs())

func get_done():
	return done

func set_done_false():
	done = false

func reset_if_done():
	if done:
		print("done!")
		reset()
