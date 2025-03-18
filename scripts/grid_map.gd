class_name Chunk extends GridMap

var blocks: Array[Block]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh_library = preload("res://resources/blocks.tres")
	if len(blocks) == 0:
		print("skipping editor chunk")
		return
	for x in 32:
		for y in 32:
			for z in 32:
				var index = x*32*32 + y * 32 + z
				set_cell_item(Vector3i(x,y,z), blocks[index].id)

func delete_chunk():
	for x in 32:
		for y in 32:
			for z in 32:
				#var index = x*32*32 + y * 32 + z
				#set_cell_item(Vector3i(x,y,z), blocks[index].id)
				set_cell_item(Vector3i(x,y,z), -1)
				print("Set block (%d, %d, %d) to %d" % [x,y,z,get_cell_item(Vector3(x,y,z))])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func destroy_block(world_coordinate: Vector3) -> void:
	var map_coordinate = local_to_map(to_local(world_coordinate))
	print("Block was %d" % get_cell_item(map_coordinate))
	print(map_coordinate)
	set_cell_item(map_coordinate, -1)

func generate():
	print("Generating chunk")
	for x in 32:
		for y in 32:
			for z in 32:
				var index = x*32*32 + y * 32 + z
				blocks.append(Block.new())
				if y == 0:
					blocks[index].id = 9
