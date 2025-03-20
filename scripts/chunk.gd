@tool
extends MeshInstance3D
class_name Chunk

@export var update_mesh: bool
static var chunk_size: int = 32
@export var surface_treshold: float = 0.0
var do_culling: bool = true
var noise_scale: float = 2.0

var a_mesh: ArrayMesh
var vertices: PackedVector3Array
var indices: PackedInt32Array
var uvs: PackedVector2Array

var face_count = 0
const tex_div: float = 0.25

enum BlockType {Air, Dirt}
var blocks: Array = []
enum Side {Up, North, East, South, West, Down}
var opaque = []

@onready var world: Node3D = $".."

func _init(mat) -> void:
	self.material_override = mat
	# TODO: FIX
	#for s in Side:
		#opaque.append([])
		#for s2 in Side:
			#opaque[int(s)][int(s2)] = false
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_block_array()
	gen_chunk()


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
				var height = noise.get_noise_2d((x + position.x) * noise_scale, (z + position.z) * noise_scale) + 1
				height *= chunk_size / 2
				if  y + surface_treshold + position.y > height:
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
	
	# ignore empty chunks
	if len(vertices) == 0:
		return
	
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices
	array[Mesh.ARRAY_INDEX] = indices
	array[Mesh.ARRAY_TEX_UV] = uvs
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	mesh = a_mesh

func need_render(pos: Vector3, side: Chunk.Side) -> bool:
	match side:
		Side.Up:
			var c = world.get_chunk(position + Vector3(0,1,0))
			var block_transparent = not block_is_opaque(pos + Vector3(0,1,0))
			var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[]
				#pass
				
			return chunk_transparent and block_transparent
		Side.North:
			var c = world.get_chunk(position + Vector3(1,0,0))
			var block_transparent = not block_is_opaque(pos + Vector3(1,0,0))
			var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[]
				#pass
				
			return chunk_transparent and block_transparent
		Side.East:
			var c = world.get_chunk(position + Vector3(0,0,1))
			var block_transparent = not block_is_opaque(pos + Vector3(0,0,1))
			var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[]
				#pass
				
			return chunk_transparent and block_transparent
		Side.South:
			var c = world.get_chunk(position + Vector3(-1,0,0))
			var block_transparent = not block_is_opaque(pos + Vector3(-1,0,0))
			var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[]
				#pass
				
			return chunk_transparent and block_transparent
		Side.West:
			var c = world.get_chunk(position + Vector3(0,0,-1))
			var block_transparent = not block_is_opaque(pos + Vector3(0,0,-1))
			var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[]
				#pass
				
			return chunk_transparent and block_transparent
		Side.Down:
			var c = world.get_chunk(position + Vector3(0,-1,0))
			var block_transparent = not block_is_opaque(pos + Vector3(0,-1,0))
			var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[]
				#pass
				
			return chunk_transparent and block_transparent
		_:
			return false

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
	if need_render(pos, Side.Up):
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(0.5, 0.5, 0.5))
		add_indices()
		add_uv(Vector2(0,0))
	
	# North
	if need_render(pos, Side.North):
		vertices.append(pos + Vector3(0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(0.5, -0.5, 0.5))
		add_indices()
		add_uv(Vector2(1,0))
	
	# East
	if need_render(pos, Side.East):
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))
		add_indices()
		add_uv(Vector2(2,0))
	
	# South
	if need_render(pos, Side.South):
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))
		add_indices()
		add_uv(Vector2(3,0))
	
	# West
	if need_render(pos, Side.West):
		vertices.append(pos + Vector3(0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(0.5, -0.5, -0.5))
		add_indices()
		add_uv(Vector2(0,1))
	
	# Down
	if need_render(pos, Side.Down):
		vertices.append(pos + Vector3(0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))
		add_indices()
		add_uv(Vector2(1,1))
	
