extends KinematicBody

# Exported variables
export var speed = 10
export var sprint_multiplier = 1.5  # Sprint speed multiplier
export var crouch_speed_multiplier = 0.5  # Speed multiplier when crouching
export var acceleration = 5
export var gravity = 0.98
export var jump_power = 30
export var mouse_sensitivity = 0.3
export var crouch_scale = 0.5  # Scale factor for crouching

# Nodes
onready var head = $Head
onready var camera = $Head/Camera

# Variables
var velocity = Vector3()
var camera_x_rotation = 0
var is_crouching = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		var x_delta = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90:
			camera.rotate_x(deg2rad(-x_delta))
			camera_x_rotation += x_delta

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.is_action_just_pressed("crouch"):
		is_crouching = true
		head.scale.y = crouch_scale if is_crouching else 1
	else:
		is_crouching = false

func _physics_process(delta):
	var head_basis = head.get_global_transform().basis
	var movement_vector = Vector3()

	if Input.is_action_pressed("movement_forward"):
		movement_vector -= head_basis.z
	if Input.is_action_pressed("movement_backward"):
		movement_vector += head_basis.z
	if Input.is_action_pressed("movement_left"):
		movement_vector -= head_basis.x
	if Input.is_action_pressed("movement_right"):
		movement_vector += head_basis.x

	movement_vector = movement_vector.normalized()

	var current_speed = speed
	if Input.is_action_pressed("sprint") and not is_crouching:
		current_speed *= sprint_multiplier
	elif is_crouching:
		current_speed *= crouch_speed_multiplier

	velocity = velocity.linear_interpolate(movement_vector * current_speed, acceleration * delta)
	velocity.y -= gravity

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y += jump_power

	velocity = move_and_slide(velocity, Vector3.UP)
