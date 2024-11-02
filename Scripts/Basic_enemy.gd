extends Node3D

var curve_3d:Curve3D
var enemy_progres:float = 0
var enemy_speed:float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	curve_3d = Curve3D.new()
	
	for i in PathGeneratorInstance.get_path_route():
		curve_3d.add_point(Vector3(i.x,0,i.y))
		
	$Path3D.curve = curve_3d
	$Path3D/PathFollow3D.progress_ratio = 0

func _on_spawning_state_entered():
	$AnimationPlayer.play("Spawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_traveling")

func _on_travelling_state_processing(delta):
	enemy_progres += delta * enemy_speed
	$Path3D/PathFollow3D.progress = enemy_progres
	
	if enemy_progres > PathGeneratorInstance.get_path_route().size():
		$EnemyStateChart.send_event("to_despawning")
