extends Area

signal on_enter()

func _ready():
	connect("body_entered", self, "on_body_entered")

func on_body_entered(body: Node):
	emit_signal("on_enter")