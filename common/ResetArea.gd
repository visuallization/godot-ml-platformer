extends Area

signal on_enter()

func _ready():
	connect("body_entered", self, "on_body_entered")

func get_size():
	var size: Vector3 = get_node("CollisionShape").shape.extents
	return size

func on_body_entered(body: Node):
	emit_signal("on_enter")