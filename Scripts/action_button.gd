extends Button

@export var action_button_icon:Texture2D
@export var action_draggable:PackedScene
@export var action_cost:int = 60
@onready var main = $"../.."

var is_dragging:bool = false
var draggable:Node
var cam:Camera3D
var RAYCAST_LENGTH:int = 100
var is_valid_location:bool = false
var last_valid_location:Vector3
var _drag_alpha:float = 0.5
@onready var error_mat:BaseMaterial3D = preload("res://materials/red_transparent.material")


# Called when the node enters the scene tree for the first time.
func _ready():
	icon = action_button_icon
	draggable = action_draggable.instantiate()
	draggable.set_patrolling(false)
	add_child(draggable)
	draggable.visible = true
	cam = get_viewport().get_camera_3d()
	
func _process(_delta):
	disabled = action_cost > main.money
	
func _physics_process(_delta):
	if is_dragging:
		var space_state = draggable.get_world_3d().direct_space_state
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		var origin:Vector3 = cam.project_ray_origin(mouse_pos)
		var end:Vector3 = origin + cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		var rayResult:Dictionary = space_state.intersect_ray(query)
		if rayResult.size() > 0:
			var co:CollisionObject3D = rayResult.get("collider")
			if co.get_groups()[0] == 'grid_empty':
				draggable.global_position = Vector3(co.global_position.x, 0.2, co.global_position.z)
				draggable.visible = true
				is_valid_location = true
				last_valid_location = Vector3(co.global_position.x, 0.2, co.global_position.z)
				clear_material_overrides(draggable)
			else: 
				is_valid_location = false
				draggable.visible = true
				draggable.global_position = Vector3(co.global_position.x, 0.2, co.global_position.z)
				set_child_mesh_error(draggable)
		else:
			draggable.visible = false
			
func set_mesh_alpha(mesh_3d:MeshInstance3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, mesh_3d.mesh.surface_get_material(si).duplicate(true))
		mesh_3d.get_surface_override_material(si).transparency = 1
		mesh_3d.get_surface_override_material(si).albedo_color.a = _drag_alpha
			
func set_child_mesh_error(n:Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			set_mesh_error(c)
		
		if c is Node and c.get_child_count() > 0:
			set_child_mesh_error(c)
			
func set_mesh_error(mesh_3d:MeshInstance3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, error_mat)

func clear_material_overrides(n:Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			clear_material_override(c)
		
		if c is Node and c.get_child_count() > 0:
			clear_material_overrides(c)
			
func clear_material_override(mesh_3d:MeshInstance3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, null)
		
func _on_button_down():
	is_dragging = true

func _on_button_up():
	is_dragging = false
	draggable.visible = false
	
	if is_valid_location:
		var action = action_draggable.instantiate()
		add_child(action)
		action.global_position = last_valid_location
		main.money -= action_cost
