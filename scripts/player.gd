extends CharacterBody3D


const SPEED = 10.0
var creative_speed = 10.0
const JUMP_VELOCITY = 7
const GRAVITY = Vector3(0, -9.8, 0)

var sensitivity = 0.002
var creative_mode = true
@onready var camera: Camera3D = $Camera3D
@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var fps: Label = $Camera3D/FPS
@onready var looking_at: Label = $"Camera3D/Looking At"

@onready var world: Node3D = $".."

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y = rotation.y - event.relative.x * sensitivity
		camera.rotation.x = camera.rotation.x - event.relative.y * sensitivity
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(175))
		

func _process(delta: float) -> void:
	if fps:
		fps.text = str(Engine.get_frames_per_second())
		
	

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_creative"):
		creative_mode = !creative_mode
	
	# Creative movement
	if creative_mode:
		if Input.is_action_just_pressed("scroll_up"):
			creative_speed = creative_speed * 1.1
		elif Input.is_action_just_pressed("scroll_down"):
			creative_speed = creative_speed / 11 * 10

		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if Input.is_action_pressed("move_jump"):
			direction += Vector3(0,1,0)
			direction = direction.normalized()
		if Input.is_action_pressed("move_sneak"):
			direction += Vector3(0,-1,0)
			direction = direction.normalized()
		if direction:
			velocity.x = direction.x * creative_speed
			velocity.y = direction.y * creative_speed
			velocity.z = direction.z * creative_speed
		else:
			velocity.x = 0
			velocity.y = 0
			velocity.z = 0
	else:
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
	
	if Input.is_action_just_pressed("left_click"):
		var pos = raycast.get_collision_point() - raycast.get_collision_normal() * 0.5
		world.RemoveBlock(round(pos.x), round(pos.y), round(pos.z))
	if Input.is_action_just_pressed("right_click"):
		var pos = raycast.get_collision_point() + raycast.get_collision_normal() * 0.5
		world.SetBlock(round(pos.x), round(pos.y), round(pos.z), World.BlockType.Dirt)

	move_and_slide()
	
	
	if looking_at:
		if raycast.is_colliding():
			var pos = raycast.get_collision_point() - raycast.get_collision_normal() * 0.5
			looking_at.text = "Looking at X: %d, Y: %d, Z: %d" % [round(pos.x), round(pos.y), round(pos.z)]
	

func leave_chunk():
	pass
