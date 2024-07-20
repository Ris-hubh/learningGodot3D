extends RigidBody3D

@export var SPEED := 1.5
const JUMP_VELOCITY := 12.5
var GRAVITY_MULTIPLIER := 2.5  # To make gravity feel stronger
var TERMINAL_VELOCITY := 100.0  # Maximum falling speed
const DASH_VELOCITY := 20
const DASH_DURATION := 0.2
const MAX_JUMPS := 2  # Maximum number of jumps
const MAX_DASHES := 2  # Maximum number of dashes
const AIR_CONTROL_FACTOR := 0.5  # Air control multiplier

var mouse_sensivity := 0.001
var twist_input := 0.0 #Variables to store the player's input for turning 
var pitch_input := 0.0 #Variables to store the player's input for looking up/down.

@onready var twist_pivot := $TwistPivot           # Node for handling horizontal rotation.
@onready var pitch_pivot := $TwistPivot/PitchPivot #Node for handling vertical rotation.
@onready var Ground_check := $RayCast3D     # A Timer node to manage the duration of the dash.
@onready var dash_timer := $DashTimer    # A Timer node to manage the duration of the dash.

var is_dashing := false
var is_on_ground := false
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") #The gravity value from the project settings.
var jump_count := 0  # Number of jumps made
var dash_count := 0  # Number of dashes made
var can_dash := true  # Whether the player can dash.

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Hides the mouse cursor and locks it in the center of the screen
	dash_timer.connect("timeout", Callable(self, "_on_dash_timeout")) #Connects the dash timer's timeout signal to the _on_dash_timeout function.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("dash")  and dash_count < MAX_DASHES and can_dash: 
		_start_dash(delta)
		print("dashing")
		
	# Ground Check (using RayCast3D)
	is_on_ground = Ground_check.is_colliding()

	# Handle Gravity and Jumping
	if not is_on_ground and not is_dashing:
		linear_velocity.y = max(linear_velocity.y - gravity * GRAVITY_MULTIPLIER * delta, -TERMINAL_VELOCITY)
		#Ensures the player’s falling speed doesn’t exceed the terminal velocity, meaning they will fall at a maximum speed and not any faster.
		
		
	if Input.is_action_just_pressed("Jump") and jump_count < MAX_JUMPS:  #and is_on_ground:
		apply_central_impulse(Vector3(0, JUMP_VELOCITY, 0)) #Applies an impulse on Y axis to make the player jump.
		jump_count += 1
		print("Jumping")
		
	if is_on_ground:
		jump_count = 0  # Reset jump count when on the ground
		dash_count = 0  # Reset dash count when on the ground
		
	# Movement
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right") * SPEED           
	input.z = Input.get_axis("move_forward", "move_backward") * SPEED
	
	if not is_on_ground:
		# Reduce the speed in the air for more control
		input *= AIR_CONTROL_FACTOR
		
	apply_central_force(twist_pivot.basis * input * 1200.0 * delta) 
	
	if Input.is_action_just_pressed("ui_cancel"): # esc to show mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print("running 13")
	
	twist_pivot.rotate_y(twist_input) #Rotates the player horizontally.
	pitch_pivot.rotate_x(pitch_input) #Rotates the player vertically.
	pitch_pivot.rotation.x = clamp(    #Limits the vertical rotation to a range.
		pitch_pivot.rotation.x, 
		deg_to_rad(-30),
		deg_to_rad(30)
	)

	twist_input = 0.0 
	pitch_input = 0.0
#Ensures that the inputs for the next frame or input cycle start from zero. This prevents cumulative rotation and maintains smooth and controlled input handling.

func _unhandled_input(event: InputEvent) -> void: #Handles input events that haven't been handled elsewhere.
	if event is InputEventMouseMotion: #Handles input events that haven't been handled elsewhere.
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensivity # - is used else inverted
			pitch_input = -event.relative.y * mouse_sensivity  # Stores the mouse movement values.

# Start the dash
func _start_dash(delta):
	gravity  = 0  # turning Off gravity while dashing
	is_dashing = true
	dash_count += 1
	can_dash = false  # Disable dashing until the timer resets
	dash_timer.start(DASH_DURATION)
	
	# Calculate dash direction based on input
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backward")
	
	# Ensure input is not zero to prevent no movement
	if input.length() == 0:
		input = Vector3.FORWARD
	
	apply_central_force(twist_pivot.basis * input * 1200.0 * DASH_VELOCITY * delta) 
	#apply_central_force() is used to apply a force that moves the RigidBody3D.
	#twist_pivot.basis ensures the force is applied in the correct direction based on the pivot's orientation.
	#1200.0 and DASH_VELOCITY adjust the strength of the force.
	# delta makes the force application consistent across different frame rates.
	linear_velocity.y = 0 # Optionally, reset vertical velocity to ensure consistent dashing behavior

# Called when the dash timer times out
func _on_dash_timeout():
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  #turning back on gravity after dashing
	is_dashing = false
	can_dash = true  # Re-enable dashing after the timer resets
