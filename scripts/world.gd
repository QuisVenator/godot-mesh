@tool

extends Node3D
class_name World

@export_tool_button("Clear", "Callable") var clear_action = Clear_chunks
@export_tool_button("Generate", "Callable") var generate_action = Generate_chunks
@export var map_size: Vector3i = Vector3i(10,1,10)
@export var noise_scale: float = 0.5
@export var cave_noise_scale: float = 2.0
@export var seed: int = 123

var existing_chunks: Dictionary = {}
var chunk_count: int = 1
var noise: FastNoiseLite
var cave_noise: FastNoiseLite

enum BlockType {Air, Dirt}

var mat = load("res://resources/gridmat.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	cave_noise = FastNoiseLite.new()
	cave_noise.seed = seed
	cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
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
				var c = Chunk.new(mat)
				existing_chunks[Vector3i(x,y,z)] = c
				c.position = Vector3(x*c.chunk_size,y*c.chunk_size,z*c.chunk_size)
				add_child(c)
				
				await Engine.get_main_loop().process_frame
	
	
func Clear_chunks():
	var children = get_children()
	for c in children:
		if c is Chunk:
			c.free()

func get_block(x, y, z):
	var height = noise.get_noise_2d(x * noise_scale, z * noise_scale) + 1
	
	height *= Chunk.chunk_size / 2
	if  y > height:
		return BlockType.Air
	else:
		var cn = cave_noise.get_noise_3d(x*cave_noise_scale,y*cave_noise_scale,z*cave_noise_scale)
		if cn > -0.3:
			return BlockType.Dirt
		else:
			return BlockType.Air

func get_chunk(pos: Vector3):
	return null
