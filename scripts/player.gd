extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 7
const GRAVITY = Vector3(0, -9.8, 0)

var sensitivity = 0.002
@onready var camera: Camera3D = $Camera3D
@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var coordinates: Label = $Camera3D/Label
@onready var chunk_coordinates: Label = $"Camera3D/Chunk Coordinates"
@onready var fps: Label = $Camera3D/FPS
@onready var looking_at: Label = $"Camera3D/Looking At"

# Debug generate new chunk
var chunks: Array[GridMap]
#const Chunk = preload("res://scenes/chunk.tscn")
@onready var debug_chunk: GridMap = $"../GridMap"
@onready var world: Node3D = $".."
var InitialChunkCoordinates: Vector3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	debug_chunk.generate()
	chunks.append(debug_chunk)
	InitialChunkCoordinates = debug_chunk.position - Vector3(128,0,0) #This is due to me making mistakes in editor

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y = rotation.y - event.relative.x * sensitivity
		camera.rotation.x = camera.rotation.x - event.relative.y * sensitivity
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(175))
	elif event is InputEventKey and event.is_action_pressed("debug_generate_chunk"):
		var new_chunk = Chunk.new()
		new_chunk.generate()
		new_chunk.position += Vector3(64, 0, 0) * len(chunks) + InitialChunkCoordinates
		chunks.append(new_chunk)
		world.add_child(new_chunk)
		

func _process(delta: float) -> void:
	if coordinates:
		coordinates.text = "X: %.1f  Y: %.1f  Z: %.1f" % [position.x, position.y, position.z]
	if fps:
		fps.text = str(Engine.get_frames_per_second())
	if chunk_coordinates:
		var chunkpos = get_current_chunk()
		chunk_coordinates.text = "X: %.1f  Y: %.1f  Z: %.1f" % [chunkpos.x, chunkpos.y, chunkpos.z]
			
		
		
	

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
	
	
	if looking_at:
		if raycast.is_colliding():
			var pos = raycast.get_collision_point() - raycast.get_collision_normal()
			looking_at.text = "Looking at X: %f, Y: %f, Z: %f" % [pos.x, pos.y, pos.z]
			
	if Input.is_action_just_pressed("left_click"):
		if raycast.is_colliding():
			if raycast.get_collider().has_method("destroy_block"):
				raycast.get_collider().destroy_block(raycast.get_collision_point() - raycast.get_collision_normal())
	

func get_current_chunk() -> Vector3:
	var current_chunk = position
	current_chunk.x = floor(current_chunk.x / 64)
	current_chunk.y = floor(current_chunk.y / 64)
	current_chunk.z = floor(current_chunk.z / 64)
	
	return current_chunk
	

func leave_chunk():
	pass
