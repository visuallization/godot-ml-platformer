extends Area

signal game_over()

func _ready():
	connect("body_entered", self, "on_body_entered")

func on_body_entered(body: Node):
	emit_signal("game_over")