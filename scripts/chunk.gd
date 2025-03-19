@tool
extends MeshInstance3D

@export var update_mesh: bool
@export var chunk_size: int = 32
@export var surface_treshold: float = 0.0
@export var do_culling: bool = false
@export var noise_scale: float = 1.0

var a_mesh: ArrayMesh
var vertices: PackedVector3Array
var indices: PackedInt32Array
var uvs: PackedVector2Array

var face_count = 0
const tex_div: float = 0.25

enum BlockType {Air, Dirt}
var blocks: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if update_mesh:
		init_block_array()
		gen_chunk()
		update_mesh = false
		

func init_block_array() -> void:
	blocks = []
	var rand = RandomNumberGenerator.new()
	var noise = FastNoiseLite.new()
	noise.seed = 123
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	for x in chunk_size:
		for y in chunk_size:
			for z in chunk_size:
				var height = noise.get_noise_2d(x * noise_scale, z * noise_scale) + 1
				height *= chunk_size / 2
				if  y + surface_treshold > height:
					blocks.append(BlockType.Air)
				else:
					blocks.append(BlockType.Dirt)

func add_uv(tpos: Vector2) -> void:
	uvs.append(Vector2(tpos.x * tex_div, tpos.y * tex_div))
	uvs.append(Vector2(tpos.x * tex_div + tex_div, tpos.y * tex_div))
	uvs.append(Vector2(tpos.x * tex_div + tex_div, tpos.y * tex_div + tex_div))
	uvs.append(Vector2(tpos.x * tex_div, tpos.y * tex_div + tex_div))

func add_indices() -> void:
	indices.append(face_count * 4 + 0)
	indices.append(face_count * 4 + 1)
	indices.append(face_count * 4 + 2)
	indices.append(face_count * 4 + 0)
	indices.append(face_count * 4 + 2)
	indices.append(face_count * 4 + 3)
	face_count += 1

func gen_chunk() -> void:
	a_mesh = ArrayMesh.new()
	vertices = PackedVector3Array()
	indices = PackedInt32Array()
	uvs = PackedVector2Array()
	face_count = 0
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			for z in range(chunk_size):
				if blocks[x * chunk_size * chunk_size + y * chunk_size + z] == BlockType.Dirt:
					gen_cube(Vector3(x,y,z))
	
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices
	array[Mesh.ARRAY_INDEX] = indices
	array[Mesh.ARRAY_TEX_UV] = uvs
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	mesh = a_mesh

func block_is_opaque(pos: Vector3) -> bool:
	if not do_culling:
		return false
	if pos.x >= chunk_size or pos.y >= chunk_size or pos.z >=chunk_size:
		return false
	if pos.x < 0 or pos.y < 0 or pos.z < 0:
		return false
	return blocks[pos.x * chunk_size * chunk_size + pos.y * chunk_size + pos.z] != BlockType.Air

func gen_cube(pos: Vector3) -> void:
	# TOP
	if not block_is_opaque(pos + Vector3(0,1,0)):
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(0.5, 0.5, 0.5))
		add_indices()
		add_uv(Vector2(0,0))
	
	# North
	if not block_is_opaque(pos + Vector3(1,0,0)):
		vertices.append(pos + Vector3(0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(0.5, -0.5, 0.5))
		add_indices()
		add_uv(Vector2(1,0))
	
	# East
	if not block_is_opaque(pos + Vector3(0,0,1)):
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))
		add_indices()
		add_uv(Vector2(2,0))
	
	# South
	if not block_is_opaque(pos + Vector3(-1,0,0)):
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))
		add_indices()
		add_uv(Vector2(3,0))
	
	# West
	if not block_is_opaque(pos + Vector3(0,0,-1)):
		vertices.append(pos + Vector3(0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(0.5, -0.5, -0.5))
		add_indices()
		add_uv(Vector2(0,1))
	
	# Down
	if not block_is_opaque(pos + Vector3(0,-1,0)):
		vertices.append(pos + Vector3(0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))
		add_indices()
		add_uv(Vector2(1,1))
	
