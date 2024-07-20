extends CharacterBody3D

@export var speed: float = 2.0
@export var smooth_factor: float = 10.0 #how smoothly the character turns towards its target.

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D #gets the NavigationAgent3D node as soon as the scene is ready
@onready var player = get_node("/root/Node3D/Player") # finds and stores a reference to the player node in the scene.

#This function runs every frame. delta is the time elapsed since the last frame, which helps to make movement frame-rate independent.
func _process(delta):
	#ts the player's current position as the target position for the navigation agent. The agent will try to move towards this position.
	navigation_agent_3d.set_target_position(player.global_transform.origin)
	
	#gets the next position along the path towards the target. The navigation agent calculates this path.
	var next_path_position = navigation_agent_3d.get_next_path_position()
	
	#This calculates the direction vector from the character's current position to the next path position.
	var direction = next_path_position - global_transform.origin
	direction = direction.normalized() #ormalizes the direction vector, making it a unit vector (length of 1). This ensures the direction is used purely for its direction and not its magnitude.
	
	#velocity = velocity.lerp(direction * speed, smooth_factor * delta): This line interpolates (lerps) the current velocity towards the desired velocity. lerp smooths the transition, making movement appear more natural. direction * speed gives the target velocity, and smooth_factor * delta controls how quickly the character turns towards this velocity.
	velocity = velocity.lerp(direction * speed, smooth_factor * delta) #velocity is the current speed.
	move_and_slide() #ormalizes the direction vector, making it a unit vector (length of 1). This ensures the direction is used purely for its direction and not its magnitude.
