extends CharacterBody3D

var mouse_movement: Vector2 = Vector2.ZERO
var mouse_moved: bool = false

var speed
const WALK_SPEED: float = 7.0
const SPRINT_SPEED: float = 10.0
const JUMP_VELOCITY: float = 9.8
const SENSITIVITY: float = 0.004

# Bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob: float = 0.0

# FOV variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Weapon sway variables
const WEAPON_SWAY_AMOUNT = 10.0
const WEAPON_SWAY_SPEED = 0.9998253

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = 9.8

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var weapon_pivot: Node3D 


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
		mouse_moved = true
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_on_wall_only():
			velocity = Vector3(get_wall_normal().x * JUMP_VELOCITY*2.5,JUMP_VELOCITY/1.5,get_wall_normal().z * JUMP_VELOCITY*2.5)
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV
	var velocity_clamped: float = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov: float = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	move_and_slide()
	camera_tilt(input_dir, delta)
	weapon_sway(delta)
	if mouse_moved:
		mouse_moved = false
	elif mouse_movement != Vector2.ZERO:
		mouse_movement = Vector2.ZERO


func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func camera_tilt(input_vector: Vector2, delta: float) -> void:
	if camera:
		camera.rotation.z = lerpf(camera.rotation.z, -input_vector.x/10 , 10 * delta)

func weapon_sway(delta: float) -> void:
	if weapon_pivot:
		weapon_pivot.rotation.x = lerpf(weapon_pivot.rotation.x, WEAPON_SWAY_AMOUNT * mouse_movement.y, 1.0 - (1.0 - WEAPON_SWAY_SPEED)**delta)
		weapon_pivot.rotation.y = lerpf(weapon_pivot.rotation.y, WEAPON_SWAY_AMOUNT * mouse_movement.x, 1.0 - (1.0 - WEAPON_SWAY_SPEED)**delta)
