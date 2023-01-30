extends Node

export (PackedScene) var platform_scene
export (PackedScene) var coin_platform_scene

onready var player = $"../Player"
onready var start_platform = $"../Platform"
onready var raycast_sensor = $"../Player/RayCastSensor3D"

var coin_platforms := []

var player_start_transform: Transform
var platform_start_position: Vector3
export var platform_spawn_distance: float = 20.0

var rng

const MAX_STEPS = 10000

var n_steps := 0
var _heuristic := "player"
var done := false
var needs_reset := false
var reward = 0.0

var move_action: int
var turn_action: int
var jump_action: bool

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()

	player_start_transform = player.global_transform
	raycast_sensor.activate()

	platform_start_position = start_platform.translation

	spawn_platform(null, true)

func _physics_process(delta):
	n_steps += 1
	if n_steps >= MAX_STEPS:
		done = true
		needs_reset = true

	if needs_reset:
		reset()
		return

	var move = get_move_action()
	var turn = get_turn_action()
	var jump = get_jump_action()

	player.set_forward_input(move)
	player.set_turn_input(turn)
	player.set_jump_input(jump)
	
func on_pickup_coin():
	if is_instance_valid(start_platform):
		start_platform.queue_free()

	update_reward(1.0)
	spawn_platform()

func on_game_over():
	done = true
	update_reward(-1.0)
	reset()

func spawn_platform(spawn_origin = null, defer = false):
	var coin_platform
	if coin_platforms.size() > 1:
		coin_platform = coin_platforms.pop_front()
		coin_platform.queue_free()

	coin_platform = coin_platform_scene.instance()
	var quat = Quat()
	quat.set_euler(Vector3.UP * deg2rad(rng.randi_range(0, 360)))
	var origin = spawn_origin if spawn_origin != null else Vector3(player.translation.x, platform_start_position.y, player.translation.z)
	coin_platform.translation = origin + quat * Vector3.FORWARD * platform_spawn_distance
	coin_platform.connect("coin_collected", self, "on_pickup_coin")

	# add this deferred call, as this is needed in the _ready function
	# because the parent node is still busy setting up children
	if defer:
		get_parent().call_deferred("add_child", coin_platform)
	else:
		get_parent().add_child(coin_platform)

	coin_platforms.append(coin_platform)

func reset():
	needs_reset = false
	n_steps = 0

	if is_instance_valid(start_platform):
		start_platform.queue_free()

	for platform in coin_platforms:
		platform.queue_free()

	coin_platforms.clear()

	start_platform = platform_scene.instance()
	start_platform.translation = platform_start_position
	get_parent().add_child(start_platform)

	player.reset(player_start_transform)

	spawn_platform(Vector3(player_start_transform.origin.x, platform_start_position.y, player_start_transform.origin.z))

func set_heuristic(heuristic):
	# sets the heuristic from "human" or "model"
	self._heuristic = heuristic

func set_action(action):
	# convert actions from Discrete (0, 1, 2) to expected input values (-1, 0, +1)
	# of the character controller
	move_action = action["move"] if action["move"] <= 1 else -1
	turn_action = action["turn"] if action["turn"] <= 1 else -1
	jump_action = action["jump"] == 1

func get_action_space():
	return {
		"move": {
			"size": 3, # 0, 1, 2
			"action_type": "discrete"
		},
		"turn": {
			"size": 3, # 0, 1, 2
			"action_type": "discrete"
		},
		"jump": {
			"size": 2, # 0, 1
			"action_type": "discrete"
		}
	}

func get_move_action() -> int:
	if done:
		move_action = 0
		return move_action

	if _heuristic == "model":
		return move_action

	return int(Input.get_axis("up", "down"))
	
func get_turn_action() -> int:
	if done:
		turn_action = 0
		return turn_action

	if _heuristic == "model":
		return turn_action
	
	return int(Input.get_axis("right", "left"))

func get_jump_action() -> bool:
	if done:
		jump_action = false
		return jump_action
	
	if _heuristic == "model":
		return jump_action

	return Input.is_action_pressed("jump")

func get_obs():
	# The observation of the agent, think of what is the key information that is needed to perform the task, try to have things in coordinates that a relative to the play
	# return a dictionary with the "obs" as a key, you can have several keys

	var obs = []
	obs.append(player.get_is_grounded())
	obs.append_array(raycast_sensor.get_observation())

	return {
		"obs": obs
	}

func get_obs_space():
	# typs of observation spaces: box, discrete, repeated (for variable length observations)
	return {
		"obs": {
			"size": [len(get_obs()["obs"])],
			"space": "box"
		}
	}

func get_obs_size():
	return len(get_obs())

func get_done():
	return done

func set_done_false():
	done = false

func update_reward(value: float):
	reward += value

func get_reward():
	return reward
	# var current_reward = reward
	# reward = 0 # reset the reward to zero on every decision step
	# return current_reward

func zero_reward():
	reward = 0

func reset_if_done():
	if done:
		print("done!")
		reset()
