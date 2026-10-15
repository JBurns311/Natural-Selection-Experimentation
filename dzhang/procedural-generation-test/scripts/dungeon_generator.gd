@tool
class_name DungeonGenerator extends Node2D

var room_dict: Dictionary[Vector2i,Room]

@export var gen_seed: int = 0
@export var randomize_seed: bool = true
@export var dungeon_room_dimensions: Vector2i = Vector2i(10,10)

@export var room_pos_start: Vector2i = Vector2i(3, 3)
@export var critical_path_length: int = 5
@export_tool_button("Generate Dungeon") var dungeon_gen_button = generate_dungeon
@export var tilemap_layer: TileMapLayer


class Room:
	const MAX_SIZE: Vector2i = Vector2i(15, 15)
	const MIN_SIZE: Vector2i = Vector2i(5, 5)
	var pos: Vector2i
	var dimensions: Vector2i
	enum TYPE {
		SOURCE,
		CONNECTOR,
		END
	}
	var type: TYPE
	
	func _init(_pos: Vector2i, _type: Room.TYPE) -> void:
		pos = _pos
		type = _type
		
	func generate(tilemap: TileMapLayer) -> void:
		var tile_pos: Vector2i = Vector2i(pos.x * MAX_SIZE.x, pos.y * MAX_SIZE.y)
		dimensions = Vector2i(randi_range(MIN_SIZE.x, MAX_SIZE.x), randi_range(MIN_SIZE.y, MAX_SIZE.y))
		for y in range(tile_pos.y, dimensions.y + tile_pos.y):
			for x in range(tile_pos.x, dimensions.x + tile_pos.x):
				if (x == tile_pos.x or x == tile_pos.x + dimensions.x - 1 or
				y == tile_pos.y or y == tile_pos.y + dimensions.y - 1):
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))
				else:
					tilemap.set_cell(Vector2i(x,y), 0, Vector2i(2, 2))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_dungeon()
	
func generate_dungeon() -> void:
	if randomize_seed:
		gen_seed = randi()
	seed(gen_seed)
	
	room_dict.clear()
	_place_entrance()
	_generate_critical_path(room_pos_start, critical_path_length)
	_generate_tilemap();
	_print_dungeon()

func _place_entrance() -> void:
	if room_pos_start.x < 0 or room_pos_start.x >= dungeon_room_dimensions.x:
		return
	if room_pos_start.y < 0 or room_pos_start.y >= dungeon_room_dimensions.y:
		return
	room_dict[room_pos_start] = Room.new(room_pos_start, Room.TYPE.SOURCE)

func _generate_critical_path(from: Vector2i, length: int) -> bool:
	if length == 0:
		return true
	var current: Vector2i = from
	var direction: Vector2i
	match randi_range(0, 3):
		0:
			direction = Vector2i.UP
		1:
			direction = Vector2i.RIGHT
		2:
			direction = Vector2i.DOWN
		3:
			direction = Vector2i.LEFT
		
	for i in 4:	
		if (current.x + direction.x >= 0 and current.x + direction.x < dungeon_room_dimensions.x and 
		current.y + direction.y >= 0 and current.y + direction.y < dungeon_room_dimensions.y and 
		!room_dict.has(current + direction)):
			current += direction
			var room_type: Room.TYPE
			if length == 1:
				room_type = Room.TYPE.END
			else:
				room_type = Room.TYPE.CONNECTOR
				
			room_dict[current] = Room.new(current, room_type)
			if _generate_critical_path(current, length - 1):
				return true
			else:
				room_dict.erase(current)
				current -= direction
			direction = Vector2i(direction.y, -direction.x)
	return false
	
func _generate_tilemap() -> void:
	if tilemap_layer:
		tilemap_layer.clear()
	for room in room_dict.values():
		room.generate(tilemap_layer)
	
func _print_dungeon() -> void:
	var dungeon_as_string: String = ""
	#print(dungeon_room_dimensions)
	for y in dungeon_room_dimensions.y:
		for x in dungeon_room_dimensions.x:
			#print("x = " + str(x))
			#print("y = " + str(y))
			if room_dict.has(Vector2i(x, y)):
				dungeon_as_string += "[" + str(room_dict.get(Vector2i(x, y)).type) + "]"
			else:
				dungeon_as_string += "[ ]"
		dungeon_as_string += '\n'
	print(dungeon_as_string)
