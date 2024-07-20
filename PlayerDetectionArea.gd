extends Area3D

@onready var enemy = get_parent()  # Assuming the script is a child of NavigationRegion3D
@onready var player = get_tree().root.get_node("Node3D/Player")  # Adjust path as needed

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body == player:
		enemy.set_target_position(player.global_transform.origin)
