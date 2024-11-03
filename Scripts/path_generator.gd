extends Node
class_name PathGenerator

var path_config:PathGeneratorConfig = preload("res://resources/basic_path_config.res")

var path_route: Array[Vector2i]

func _init():
	generate_path()
	
func generate_path():
	path_route.clear()
	randomize()
	
	var x = 0
	var y = int(path_config.map_height/2.0)
	
	while x < path_config.map_length:
		if not path_route.has(Vector2i(x,y)):
			path_route.append(Vector2i(x,y))
			
		var choice : int = randi_range(0,2)
		
		if choice == 0 or x < 2 or x % 2 == 0 or x == path_config.map_length-1:
			x += 1
		elif choice == 1 and y < path_config.map_height-2 and not path_route.has(Vector2i(x,y+1)):
			y += 1
		elif choice == 2 and y > 1 and not path_route.has(Vector2i(x,y-1)):
			y -= 1
		
	return path_route
	
func get_tile_score(index:int) -> int:
	var score:int = 0
	var x = path_route[index].x
	var y = path_route[index].y
	
	score += 1 if path_route.has(Vector2i(x,y-1)) else 0
	score += 2 if path_route.has(Vector2i(x+1,y)) else 0
	score += 4 if path_route.has(Vector2i(x,y+1)) else 0
	score += 8 if path_route.has(Vector2i(x-1,y)) else 0
	
	return score
	
func get_path_route() -> Array[Vector2i]:
	return path_route
	
func get_path_tile(index:int) -> Vector2i:
	return path_route[index]


