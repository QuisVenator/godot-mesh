extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 6
const GRAVITY = Vector3(0, -9.8, 0)

var sensitivity = 0.002
@onready var camera: Camera3D = $Camera3D
@onready var coordinates: Label = $Camera3D/Label

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y = rotation.y - event.relative.x * sensitivity
		camera.rotation.x = camera.rotation.x - event.relative.y * sensitivity
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(175))
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()
	
	coordinates.text = "X: %.1f  Y: %.1f  Z: %.1f" % [position.x, position.y, position.z]
