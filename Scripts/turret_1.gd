extends Node3D

var enemies_in_range:Array[Node3D]
var current_enemy:Node3D = null
var current_enemy_targetted:bool = false
var acquire_slerp_progress:float = 0
var current_enemy_class:Enemy = null

var last_fire_time:int
@export var fire_rate_ms:int = 1000
@export var projectile_type:PackedScene

func _on_patrol_zone_area_entered(area):
	if current_enemy == null:
		current_enemy = area
	enemies_in_range.append(area)
	print(enemies_in_range.size())
	
func _on_patrol_zone_area_exited(area):
	enemies_in_range.erase(area)
	print(enemies_in_range.size())
	
func set_patrolling(patrolling:bool):
	$PatrolZone.monitoring = patrolling
	
func rotate_towards_target(rtarget, delta):
	var target_vector = $"weapon-cannon".global_position.direction_to(Vector3(rtarget.global_position.x, global_position.y, rtarget.global_position.z))
	var target_basis:Basis = Basis.looking_at(target_vector)
	$"weapon-cannon".basis = $"weapon-cannon".basis.slerp(target_basis, acquire_slerp_progress)
	acquire_slerp_progress += delta 
	
	if acquire_slerp_progress > 1:
		$StateChart.send_event("to_attacking_state")
		
func find_enemy_parent(n: Node):
	if n is Enemy:
		return n 
	elif n.get_parent() != null:
		return find_enemy_parent(n.get_parent())
	else:
		return null

func _on_patrolling_state_state_processing(_delta):
	if enemies_in_range.size() > 0:
		current_enemy = enemies_in_range[0]
		current_enemy_class = find_enemy_parent(current_enemy)
		current_enemy_class.enemy_finished.connect(remove_current_enemy)
		$StateChart.send_event("to_acquiring_state")

func remove_current_enemy():
	enemies_in_range.erase(current_enemy)

func _on_aquiring_state_state_entered():
		current_enemy_targetted = false
		acquire_slerp_progress = 0

func _on_aquiring_state_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		rotate_towards_target(current_enemy, delta)
	else:
		print('enmie said poof')
		$StateChart.send_event("to_patrolling_state")
	

func _on_atacking_state_state_physics_processing(_delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		$"weapon-cannon".look_at(current_enemy.global_position)
		maybe_fire()
	else:
		print('enmie said poof')
		$StateChart.send_event("to_patrolling_state")
		
func maybe_fire():
	if Time.get_ticks_msec() > (last_fire_time+fire_rate_ms):
		var projectile:Projectille = projectile_type.instantiate()
		projectile.starting_position = $"weapon-cannon/Projectile_spawn".global_position
		projectile.target = current_enemy
		add_child(projectile)
		last_fire_time = Time.get_ticks_msec()
		

func _on_atacking_state_state_entered():
	last_fire_time = 0
