extends Area

export var rotation_speed := 1

signal coin_collected()

func _ready():
	connect("body_entered", self, "_on_body_entered")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(Vector3(0, 1, 0), rotation_speed * delta)

func _on_body_entered(body:Node):
	emit_signal("coin_collected")
	queue_free()