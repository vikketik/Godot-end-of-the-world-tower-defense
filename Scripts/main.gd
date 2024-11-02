extends Node3D

@export var tile_straight:PackedScene
@export var tile_corner:PackedScene
@export var tile_start:PackedScene
@export var tile_end:PackedScene
@export var tile_empty:Array[PackedScene]

@export var basic_enemy:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	_complete_grid()
	
	await get_tree().create_timer(2).timeout
	_pop_along_grid()
	
func _add_curve_point(c3d:Curve3D, v3:Vector3) ->bool:
	c3d.add_point(v3)
	return true
	
func _pop_along_grid():
	var box = basic_enemy.instantiate()
	
	add_child(box)
	
func _complete_grid():
	for x in range(PathGeneratorInstance.path_config.map_length):
		for y in range(PathGeneratorInstance.path_config.map_height):
			if not PathGeneratorInstance.get_path_route().has(Vector2i(x,y)):
				var tile:Node3D = tile_empty.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0,3)*90, 0)
		
	for i in range(PathGeneratorInstance.get_path_route().size()):
		var tile_score:int = PathGeneratorInstance.get_tile_score(i)
		
		var tile:Node3D = tile_empty[0].instantiate()
		var tile_rotation: Vector3 = Vector3.ZERO
		
#tile score acording to the tile next to it
#for example if a tile has a tile to the left off it and a tile on the bottom the score is 8+4 so 12
#   1
# 8   2
#   4
		if tile_score == 10:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 2:
			tile = tile_start.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 8:
			tile = tile_end.instantiate()
			tile_rotation = Vector3(0,-90,0)
		elif tile_score == 1 or tile_score == 4 or tile_score == 5:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 12:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,-90,0)
		elif tile_score == 6:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 3:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 9:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,-180,0)
		
		add_child(tile)
		tile.global_position = Vector3(PathGeneratorInstance.get_path_tile(i).x, 0, PathGeneratorInstance.get_path_tile(i).y)
		tile.global_rotation_degrees = tile_rotation
