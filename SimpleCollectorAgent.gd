extends Node

export (PackedScene) var platform_scene
export (PackedScene) var player_scene

onready var player = $"../Player"
onready var platform = $"../CoinPlatform"
onready var raycast_sensor = $"../Player/RayCastSensor3D"

var player_start_transform: Transform
var player_start_position: Vector3
var platform_start_position: Vector3
export var platform_spawn_distance: float = 20.0

var rng

const MAX_STEPS = 20000

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
	player_start_position = player.translation
	raycast_sensor.activate()

	platform_start_position = platform.translation

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
	done = true
	update_reward(10.0)
	reset()

func on_game_over():
	done = true
	update_reward(-1.0)
	reset()

func reset():
	needs_reset = false
	n_steps = 0

	# player.queue_free()
	# player = player_scene.instance()
	# player.translation = player_start_position
	# get_parent().add_child(player)
	
	# raycast_sensor = player.get_node("RayCastSensor3D")
	# raycast_sensor.activate()
	player.reset(player_start_transform)
	# player.transform = player_start_transform
	
	# platform.queue_free()
	# platform = platform_scene.instance()
	var quat = Quat()
	quat.set_euler(Vector3.UP * deg2rad(rng.randi_range(0, 360)))
	platform.translation = Vector3(0, platform_start_position.y, 0) + quat * Vector3.FORWARD * platform_spawn_distance
	# platform.connect("coin_collected", self, "on_pickup_coin")
	# get_parent().add_child(platform)

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
	var goal_distance = 0.0
	var goal_vector = Vector3.ZERO

	goal_distance = player.translation.distance_to(platform.translation)
	goal_vector = (platform.translation - player.translation).normalized()

	# goal_vector = goal_vector.rotated(Vector3.UP, -deg2rad(rotation_degrees.y))
	goal_distance = clamp(goal_distance, 0.0, 20.0)

	var obs = []
	# obs.append_array([
	# 					player.linear_velocity.x / 20.0,
	# 					player.linear_velocity.y / 20.0,
	# 					player.linear_velocity.z / 20.0
	# 				])
	# obs.append_array([goal_distance / 20.0,
	# 				  goal_vector.x, 
	# 				  goal_vector.y, 
	# 				  goal_vector.z])
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
