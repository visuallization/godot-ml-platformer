extends RigidBody

export var slope_limit := 45.0
export var move_speed := 5.0
export var turn_speed := 10.0
export var jump_speed := 4.0

var is_grounded := false setget , get_is_grounded
var forward_input := 0.0 setget set_forward_input, get_forward_input
var turn_input := 0.0 setget set_turn_input, get_turn_input
var jump_input := false setget set_jump_input, get_jump_input

onready var capsule_collider: CollisionShape = $CapsuleCollider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Hello Player!")

func _physics_process(delta) -> void:
	check_grounded()

func _integrate_forces(state) -> void:
	process_actions(state)

func check_grounded() -> void:
	is_grounded = false
	var capsule_height: float = max(capsule_collider.shape.radius * 2.0, capsule_collider.shape.height)
	var capsule_bottom: Vector3 = global_translation + (capsule_collider.translation - Vector3.UP * (capsule_collider.shape.height))
	DebugDraw.draw_sphere(capsule_bottom, 1)
	var radius: float = (scale * Vector3(capsule_collider.shape.radius, 0.0, 0.0)).length()
	# print("Translation: ", translation)
	# print("Capsule Bottom: ", capsule_bottom)
	# print("Radius ", radius)
	var space_state := get_world().direct_space_state
	var from: Vector3 = capsule_bottom + global_transform.basis.y * 0.01
	var to: Vector3 = capsule_bottom - global_transform.basis.y * 5
	var hit := space_state.intersect_ray(from, to)
	DebugDraw.draw_line(from, to, Color(0, 1, 0))
	if hit:
		var normal_angle: float = hit.normal.angle_to(global_transform.basis.y)
		if normal_angle < slope_limit:
			var max_distance = radius / cos(deg2rad(normal_angle)) - radius + 0.4
			var hit_distance = from.distance_to(hit.position)
			if hit_distance < max_distance:
				is_grounded = true
	
func process_actions(state: PhysicsDirectBodyState) -> void:
	# Rotation
	if turn_input != 0.0:
		var angle: float = clamp(turn_input, -1.0, 1.0) * turn_speed
		state.transform.basis = state.transform.basis.rotated(Vector3.UP, get_physics_process_delta_time() * angle)

	# Movement & Jumping
	if is_grounded:
		state.linear_velocity = Vector3.ZERO

		if jump_input:
			state.linear_velocity += Vector3.UP * jump_speed
		
		state.linear_velocity += -global_transform.basis.z * clamp(forward_input, -1.0, 1.0) * move_speed
	else:
		# Check if player tries to move while jumping/falling
		if not is_zero_approx(forward_input):
			# make it possible to move the player at half speed when jumping/falling
			var vertical_velocity: Vector3 = state.linear_velocity.project(Vector3.UP)
			state.linear_velocity = vertical_velocity + (-global_transform.basis.z) * clamp(forward_input, -1.0, 1.0) * move_speed / 2.0

# Setter & Getter
func get_is_grounded() -> bool:
	return is_grounded

func set_forward_input(input: float) -> void:
	forward_input = input

func get_forward_input() -> float:
	return forward_input

func set_turn_input(input: float) -> void:
	turn_input = input

func get_turn_input() -> float:
	return turn_input

func set_jump_input(input: bool) -> void:
	jump_input = input

func get_jump_input() -> bool:
	return jump_input




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
