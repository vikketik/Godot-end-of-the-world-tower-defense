extends Node3D
class_name Enemy

@export var enemy_settings:EnemySettings
@export var speed:float = 1
@export var health:int = 100
@export var destroy_value:int = 30

var attackable:bool = false
var distance_travelled:float = 0

var path_3d:Path3D
var path_follow_3d:PathFollow3D

signal enemy_finished

func _ready():
	print("Ready")
	$Path3D.curve = path_route_to_curve_3d()
	$Path3D/PathFollow3D.progress = 0
	

func _on_spawning_state_entered():
	print("Spawning")
	attackable = false
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_travelling_state")

func _on_travelling_state_entered():
	print("Travelling")
	attackable = true

func _on_travelling_state_processing(delta):
	distance_travelled += (delta * speed)
	var distance_travelled_on_screen:float = clamp(distance_travelled, 0, PathGeneratorInstance.get_path_route().size()-1)
	$Path3D/PathFollow3D.progress = distance_travelled_on_screen
	
	if distance_travelled > PathGeneratorInstance.get_path_route().size()-1:
		$EnemyStateChart.send_event("to_dying_state")

func _on_despawning_state_entered():
	enemy_finished.emit()
	$AnimationPlayer.play("despawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_remove_enemy_state")

func _on_remove_enemy_state_entered():
	queue_free()

func _on_damaging_state_entered():
	attackable = false
	print("doing some damage!")
	$EnemyStateChart.send_event("to_despawning_state")

func _on_dying_state_entered():
	get_parent_node_3d().money += destroy_value
	enemy_finished.emit()
	$audioExplosion.play()
	$"Path3D/PathFollow3D/enemy-ufo-a".visible = false
	await $audioExplosion.finished
	$EnemyStateChart.send_event("to_remove_enemy_state")
	

	
func path_route_to_curve_3d() -> Curve3D:
	var c3d:Curve3D = Curve3D.new()
	
	for element in PathGeneratorInstance.get_path_route():
		c3d.add_point(Vector3(element.x, 0.25, element.y))

	return c3d


func _on_area_3d_area_entered(area):
	if area is Projectille:
		health -= area.damage
		
	if health <= 0:
		$EnemyStateChart.send_event("to_dying_state")
