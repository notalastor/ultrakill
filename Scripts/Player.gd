class_name Player
extends CharacterBody3D

var mouse_movement: Vector2 = Vector2.ZERO
var mouse_moved: bool = false

var speed: float
var last_direction: Vector3
var slide_direction: Vector3


const WALK_SPEED: float = 7.0
const SPRINT_SPEED: float = 10.0
const SLIDE_SPEED: float = 15.0
const JUMP_VELOCITY: float = 9.8
const SENSITIVITY: float = 0.004

var sprinting: bool
var sliding: bool
var slide_time_left: float = 0.0

const SLIDE_DURATION: float = 1.5
const SLIDE_BASE_SPEED: float = 0.25
const CAMERA_Y_SLIDE_OFFSET: float = -0.75

var current_cam_y_offset: float = 0.0
var target_cam_y_offset: float = 0.0

const CAM_Y_OFFSET_FOLLOW_SPEED: float = 0.999825

# Bob variables
const BOB_FREQ: float = 2.4
const BOB_AMP: float = 0.08
var t_bob: float = 0.0

# FOV variables
const BASE_FOV: float = 75.0
const FOV_CHANGE: float = 1.5

# Weapon sway variables
const WEAPON_SWAY_AMOUNT: float = 0.02
const WEAPON_SWAY_SPEED: float = 0.9998253

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = 9.8

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var weapon_pivot: Node3D = $Head/Camera3D/CSGBox3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
		mouse_moved = true
		var adj_relative: Vector2 = event.relative * SENSITIVITY
		head.rotate_y(-adj_relative.x)
		camera.rotate_x(-adj_relative.y)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		var jumped: bool = false
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jumped = true
		elif is_on_wall_only():
			velocity = Vector3(get_wall_normal().x * JUMP_VELOCITY * 2.5, JUMP_VELOCITY / 1.5, get_wall_normal().z * JUMP_VELOCITY * 2.5)
			jumped = true
		if jumped:
			sliding = false
			slide_time_left = 0.0

	if Input.is_action_just_pressed("slide") and sprinting and not sliding:
		sliding = true
		slide_time_left = SLIDE_DURATION
		slide_direction = last_direction
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		sprinting = true
		speed = SPRINT_SPEED
	else:
		sprinting = false
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	last_direction = direction
	if sliding:
		if is_on_floor():
			var slide_vel: Vector3 = slide_direction * (SLIDE_SPEED * slide_time_left / SLIDE_DURATION + SLIDE_BASE_SPEED)
			velocity = Vector3(slide_vel.x, velocity.y, slide_vel.z)
		slide_time_left -= delta
		if slide_time_left <= 0.0:
			sliding = false
	else:
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = lerpf(velocity.x, direction.x * speed, delta * 7.0)
				velocity.z = lerpf(velocity.z, direction.z * speed, delta * 7.0)
		else:
			velocity.x = lerpf(velocity.x, direction.x * speed, delta * 3.0)
			velocity.z = lerpf(velocity.z, direction.z * speed, delta * 3.0)

	# Head bob
	if not sliding:
		t_bob += delta * velocity.length() * float(is_on_floor())

	target_cam_y_offset = CAMERA_Y_SLIDE_OFFSET * float(sliding)
	current_cam_y_offset = lerpf(current_cam_y_offset, target_cam_y_offset, 1.0 - (1.0 - CAM_Y_OFFSET_FOLLOW_SPEED)**delta)

	camera.transform.origin = _headbob(t_bob) + current_cam_y_offset * Vector3.UP

	# FOV
	var velocity_clamped: float = clampf(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov: float = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# These function calls and if/else blocks must be at the same indentation level as the other code in _physics_process.
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
		camera.rotation.z = lerpf(camera.rotation.z, -input_vector.x/10, 10 * delta)


func weapon_sway(delta: float) -> void:
	if weapon_pivot:
		weapon_pivot.rotation.x = lerpf(weapon_pivot.rotation.x, WEAPON_SWAY_AMOUNT * mouse_movement.y, 1.0 - pow(1.0 - WEAPON_SWAY_SPEED, delta))
		weapon_pivot.rotation.y = lerpf(weapon_pivot.rotation.y, WEAPON_SWAY_AMOUNT * mouse_movement.x, 1.0 - pow(1.0 - WEAPON_SWAY_SPEED, delta))
