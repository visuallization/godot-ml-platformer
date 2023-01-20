extends Node

export (PackedScene) var platform_scene
export (PackedScene) var player_scene

var player
var platform

var start_position = Vector3(0, 3, 0)

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
	reset()
	
func on_pickup_coin():
	print("pickup")

	done = true
	reset()

func reset():
	print("reset")

	if player:
		player.queue_free()

	player = player_scene.instance()
	player.translation = start_position
	add_child(player)

	if platform:
		platform.queue_free()

	platform = platform_scene.instance()
	platform.get_node("Collectible").connect("coin_collected", self, "on_pickup_coin")
	platform.translation = Vector3(rng.randi_range(-10, 10), 1.05, rng.randi_range(-10, 10))
	
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
