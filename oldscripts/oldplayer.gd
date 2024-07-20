extends RigidBody3D
#this tells us the script is attached to a rigid body 3D node and we can access
#all the properties and functions of a rigid body 3D in code
@export var SPEED := 1.5
const JUMP_VELOCITY := 8.0
var GRAVITY_MULTIPLIER := 1.5  # To make gravity feel stronger
var TERMINAL_VELOCITY := 55.0  # Maximum falling speed

var mouse_sensivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var Ground_check := $RayCast3D


var is_dashing := false
var is_on_ground := false
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	# Ground Check (using RayCast3D)
	is_on_ground = Ground_check.is_colliding()

	# Handle Gravity and Jumping
	if not is_on_ground and not is_dashing:
		#linear_velocity.y -= gravity * delta  # Apply gravity with delta
		linear_velocity.y = max(linear_velocity.y - gravity * GRAVITY_MULTIPLIER * delta, -TERMINAL_VELOCITY)

	if Input.is_action_just_pressed("Jump") and is_on_ground:
		apply_central_impulse(Vector3(0, JUMP_VELOCITY, 0))
		print("Jumping")
		
	#movement
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left","move_right") * SPEED
	input.z = Input.get_axis("move_forward","move_backward") * SPEED
	#apply_central_force(twist_pivot.basis * input * 1200.0 * delta) 
	if is_on_ground or is_dashing:
		apply_central_force(twist_pivot.basis * input * 1200.0 * delta)
	else:
		apply_central_force(twist_pivot.basis * input * 1800.0 * delta)
	
	#twist_pivot.bisis to move in camer direction not globally
	print("running 12")
	if Input.is_action_just_pressed("ui_cancel"): # esc to show mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print("running 13")
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x, 
		#-0.5 30 degree vertical limit,
		#0.5
		deg_to_rad(-30),
		deg_to_rad(30)
	)
		#resting to camer moes last direction 
	twist_input = 0.0
	pitch_input = 0.0
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		print("running 6")
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			print("running 7")
			twist_input = - event.relative.x * mouse_sensivity # - is used else inverted
			pitch_input = - event.relative.y * mouse_sensivity
			


