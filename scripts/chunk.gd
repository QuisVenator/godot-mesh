@tool
extends MeshInstance3D
class_name Chunk

static var chunk_size: int = 32

var a_mesh: ArrayMesh
var vertices: PackedVector3Array
var indices: PackedInt32Array
var uvs: PackedVector2Array

var face_count = 0
const tex_div: float = 0.25

var blocks: Array = []
enum Side {Up, North, East, South, West, Down}
enum Direction {
	UP_DOWN, 
	UP_NORTH, 
	UP_EAST, 
	UP_SOUTH, 
	UP_WEST, 
	NORTH_DOWN, 
	NORT_EAST,
	NORTH_SOUTH,
	NORTH_WEST, 
	EAST_DOWN, 
	EAST_SOUTH, 
	EAST_WEST, 
	SOUTH_DOWN, 
	SOUTH_WEST,
	WEST_DOWN
}
var opaque = []

@onready var world: Node3D = $".."

func _init(mat) -> void:
	self.material_override = mat
	for d in Direction:
		opaque.append(false)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_block_array()
	gen_chunk()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func init_block_array() -> void:
	blocks = []
	for x in chunk_size:
		blocks.append([])
		for y in chunk_size:
			blocks[x].append([])
			for z in chunk_size:
				blocks[x][y].append(world.get_block(x+position.x, y+position.y, z+position.z))

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
				if blocks[x][y][z] == World.BlockType.Dirt:
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
			return not block_is_opaque(pos + Vector3(0,1,0))
			#var c = world.get_chunk(position + Vector3(0,1,0))
			#var block_transparent = not block_is_opaque(pos + Vector3(0,1,0))
			#var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[int(Direction.UP_DOWN)]
				#
			#return chunk_transparent and block_transparent
		Side.North:
			return not block_is_opaque(pos + Vector3(1,0,0))
			#var c = world.get_chunk(position + Vector3(1,0,0))
			#var block_transparent = not block_is_opaque(pos + Vector3(1,0,0))
			#var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[int(Direction.NORTH_SOUTH)]
				#
			#return chunk_transparent and block_transparent
		Side.East:
			return not block_is_opaque(pos + Vector3(0,0,1))
			#var c = world.get_chunk(position + Vector3(0,0,1))
			#var block_transparent = not block_is_opaque(pos + Vector3(0,0,1))
			#var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[int(Direction.EAST_WEST)]
				#
			#return chunk_transparent and block_transparent
		Side.South:
			return not block_is_opaque(pos + Vector3(-1,0,0))
			#var c = world.get_chunk(position + Vector3(-1,0,0))
			#var block_transparent = not block_is_opaque(pos + Vector3(-1,0,0))
			#var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[int(Direction.NORTH_SOUTH)]
				#
			#return chunk_transparent and block_transparent
		Side.West:
			return not block_is_opaque(pos + Vector3(0,0,-1))
			#var c = world.get_chunk(position + Vector3(0,0,-1))
			#var block_transparent = not block_is_opaque(pos + Vector3(0,0,-1))
			#var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[int(Direction.EAST_WEST)]
				#
			#return chunk_transparent and block_transparent
		Side.Down:
			return not block_is_opaque(pos + Vector3(0,-1,0))
			#var c = world.get_chunk(position + Vector3(0,-1,0))
			#var block_transparent = not block_is_opaque(pos + Vector3(0,-1,0))
			#var chunk_transparent = true
			#if c:
				#chunk_transparent = not c.opaque[int(Direction.UP_DOWN)]
				#
			#return chunk_transparent and block_transparent
		_:
			return false

func block_is_opaque(pos: Vector3) -> bool:
	if pos.x < 0 or pos.x >= chunk_size or pos.y < 0 or pos.y >= chunk_size or pos.z < 0 or pos.z >= chunk_size:
		return world.get_block(pos.x+position.x, pos.y+position.y, pos.z+position.z) != World.BlockType.Air
	return blocks[pos.x][pos.y][pos.z] != World.BlockType.Air

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
	
