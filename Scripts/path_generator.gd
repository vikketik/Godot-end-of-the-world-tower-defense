extends Node
class_name PathGenerator

var grid_length : int 
var grid_height : int 

var path: Array[Vector2i]

func _init(lenght:int, height:int):
	grid_length = lenght
	grid_height = height
	
func generate_path():
	path.clear()
	
	var x = 0
	var y = int(grid_height/2)
	
	while x < grid_length:
		if not path.has(Vector2i(x,y)):
			path.append(Vector2i(x,y))
			
		var choise : int = randi_range(0,2)
		
		if choise == 0 or x % 2 == 0 or x == grid_length-1:
			x += 1
		elif choise == 1 and y < grid_height-2 and not path.has(Vector2i(x,y+1)):
			y += 1
		elif choise == 2 and y > 1 and not path.has(Vector2i(x,y-1)): 
			y -= 1
		
	return path
	
func get_tile_score(tile:Vector2i) -> int:
	var score:int = 0
	var x = tile.x
	var y = tile.y
	
	score += 1 if path.has(Vector2i(x,y-1)) else 0
	score += 2 if path.has(Vector2i(x+1,y)) else 0
	score += 4 if path.has(Vector2i(x,y+1)) else 0
	score += 8 if path.has(Vector2i(x-1,y)) else 0
	
	return score
	
func get_path_route() -> Array[Vector2i]:
	return path
	
func get_path_tile(index:int) -> Vector2i:
	return path[index]

