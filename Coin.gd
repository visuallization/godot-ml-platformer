extends StaticBody

export var rotation_speed := 1	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(Vector3(0, 1, 0), rotation_speed * delta)
