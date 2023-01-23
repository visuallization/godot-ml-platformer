extends KinematicBody

export var mouse_sensitivity := 0.1
export var movement_speed := 100

onready var _camera := $Camera

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var x = Input.get_axis("camera_left", "camera_right")
	var z = Input.get_axis("camera_up", "camera_down")
	var move: Vector3 = transform.basis.x * x + transform.basis.z * z

	move_and_slide(move * movement_speed)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_camera.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		_camera.rotation_degrees.x = clamp(_camera.rotation_degrees.x, -89.9, 89.9)
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
