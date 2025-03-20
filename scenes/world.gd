extends Node3D

var existing_chunks: Dictionary = {}
var chunk_count: int = 1
var mat = load("res://resources/gridmat.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	existing_chunks[Vector3i(0,0,0)] = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func add_chunk(pos: Vector3i) -> bool:
	if pos in existing_chunks:
		print("chunk already exists")
		return false
	
	chunk_count += 1
	existing_chunks[pos] = null
	print("generate new chunk %d" % chunk_count)
	print(pos)
	var c = Chunk.new(mat)
	c.chunk_coordinates = pos
	c.position = c.chunk_to_world_coordinates(c.chunk_coordinates)
	add_child(c)
	return true
