extends Spatial

signal coin_collected()

func _ready():
	get_node("Collectible").connect("collectible_collected", self, "on_coin_collected")

func on_coin_collected():
	emit_signal("coin_collected")

