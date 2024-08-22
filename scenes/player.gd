extends CharacterBody3D

@onready var animated_sprite_3d = $AnimatedSprite3D
@onready var grid_map = $"../GridMap"

const RAY_LENGTH = 1000
@onready var camera_3d = $"../player/Camera3D"

@export var speed = 7.0
const sprint_speed = 14.0
const jump_velocity = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Handle Fall
	if not is_on_floor():
		velocity.y -= gravity * delta
		animated_sprite_3d.play("fall")
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		animated_sprite_3d.play("jump")
		
	# Handle Walking
	if Input.is_action_pressed("left"):
		velocity.x = -speed
		animated_sprite_3d.play("walk")
	elif Input.is_action_pressed("right"):
		velocity.x = speed
		animated_sprite_3d.play("walk")
	else:
		velocity.x = 0
		animated_sprite_3d.stop()
		
	# Handle animation flip
	if velocity.x < 0.0:
		animated_sprite_3d.flip_h = true
	else:
		animated_sprite_3d.flip_h = false
		
	var space_state = get_world_3d().direct_space_state
	var cam = camera_3d
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [self]
	query.collide_with_areas = true
	query.get_method_list()
	var results = space_state.intersect_ray(query)
	print(results)
	var pos = results.get("position")
	var normal = results.get("normal")
	print(pos, normal)
	if Input.is_action_just_pressed("LMB") and results:
		grid_map.destroy_block(pos - normal)
	if Input.is_action_just_pressed("RMB") and results:
		grid_map.create_block(pos + normal)
	
	move_and_slide()
