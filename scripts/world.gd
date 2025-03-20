@tool

extends Node3D

@export_tool_button("Clear", "Callable") var clear_action = Clear_chunks
@export_tool_button("Generate", "Callable") var generate_action = Generate_chunks
@export var map_size: Vector3i = Vector3i(1,1,1)

var existing_chunks: Dictionary = {}
var chunk_count: int = 1

var mat = load("res://resources/gridmat.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Generate_chunks()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
					
func Generate_chunks() -> void:
	Clear_chunks()
	var x_off = floor(map_size.x / 2)
	var y_off = floor(map_size.y / 2)
	var z_off = floor(map_size.z / 2)
	
	for x in range(-x_off, map_size.x-x_off):
		for y in range(-y_off, map_size.y-y_off):
			for z in range(-z_off, map_size.z-z_off):
				print(x,y,z)
				var c = Chunk.new(mat)
				existing_chunks[Vector3i(x,y,z)] = c
				c.position = Vector3(x*c.chunk_size,y*c.chunk_size,z*c.chunk_size)
				add_child(c)
	
	
func Clear_chunks():
	var children = get_children()
	for c in children:
		if c is Chunk:
			c.free()
		
func get_chunk(pos: Vector3):
	return null
