class_name Player
extends CharacterBody3D

# -------------------
# PLAYER STATS
# -------------------
var max_health: int = 100
var health: int = 100

var max_ammo: int = 20
var ammo: int = 30
var is_reloading: bool = false
var reload_time: float = 1.5
var reload_ammount: int = 30
# -------------------
# MOVEMENT VARIABLES
# -------------------
var speed: float
var last_direction: Vector3
var slide_direction: Vector3
var knockback: Vector3
var knock_timer: float
var WALK_SPEED: float = 7.0
var SPRINT_SPEED: float = 10.0
var SLIDE_SPEED: float = 15.0
var JUMP_VELOCITY: float = 9.8
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

# Gravity
var gravity: float = 9.8

# Mouse
var mouse_movement: Vector2 = Vector2.ZERO
var mouse_moved: bool = false

# Scene references
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var weapon_pivot: Node3D = $Head/Camera3D/CSGBox3D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var shoot_point: Node3D = %ShootPoint

var change_scene: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation.play_backwards("fade")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
		mouse_moved = true
		var adj_relative: Vector2 = event.relative * SENSITIVITY
		head.rotate_y(-adj_relative.x)
		camera.rotate_x(-adj_relative.y)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _physics_process(delta: float) -> void:
	# -------------------
	# HEALTH & AMMO TEST
	# -------------------
	if Input.is_action_just_pressed("shoot"):
		shoot()

	if Input.is_action_just_pressed("reload"):
		if not is_reloading:
			start_reload()

	# -------------------
	# GRAVITY
	# -------------------
	if not is_on_floor():
		velocity.y -= gravity * delta

	# -------------------
	# JUMP
	# -------------------
	if Input.is_action_just_pressed("jump"):
		var jumped: bool = false
		if is_on_floor_only():
			velocity.y = JUMP_VELOCITY
			jumped = true
		if is_on_wall_only():
			velocity = Vector3(get_wall_normal().x * JUMP_VELOCITY * 2.5, JUMP_VELOCITY / 1.5, get_wall_normal().z * JUMP_VELOCITY * 2.5)
			jumped = true
		if jumped:
			sliding = false
			slide_time_left = 0.0

	# -------------------
	# SLIDE
	# -------------------
	if Input.is_action_just_pressed("slide") and sprinting and not sliding and is_on_floor():
		sliding = true
		slide_time_left = SLIDE_DURATION
		slide_direction = last_direction

	# -------------------
	# SPRINT
	# -------------------
	if Input.is_action_pressed("sprint"):
		sprinting = true
		speed = SPRINT_SPEED
	else:
		sprinting = false
		speed = WALK_SPEED

	# -------------------
	# MOVEMENT
	# -------------------
	if knock_timer <= 0.0:
		var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
		camera_tilt(input_dir, delta)
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
	else:
		knock_back_apply(delta)

	# -------------------
	# HEAD BOB
	# -------------------
	if not sliding:
		t_bob += delta * velocity.length() * float(is_on_floor())

	target_cam_y_offset = CAMERA_Y_SLIDE_OFFSET * float(sliding)
	current_cam_y_offset = lerpf(current_cam_y_offset, target_cam_y_offset, 1.0 - (1.0 - CAM_Y_OFFSET_FOLLOW_SPEED) ** delta)

	camera.transform.origin = _headbob(t_bob) + current_cam_y_offset * Vector3.UP

	# -------------------
	# FOV
	# -------------------
	var velocity_clamped: float = clampf(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov: float = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	# -------------------
	# MOVEMENT APPLY
	# -------------------
	move_and_slide()

	# -------------------
	# WEAPON SWAY
	# -------------------
	weapon_sway(delta)

	# -------------------
	# RESET MOUSE STATE
	# -------------------
	if mouse_moved:
		mouse_moved = false
	elif mouse_movement != Vector2.ZERO:
		mouse_movement = Vector2.ZERO

	# -------------------
	# SCENE CHANGE
	# -------------------
	if change_scene:
		change_effect()


# ===================
# EXTRA FUNCTIONS
# ===================

func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func camera_tilt(input_vector: Vector2, delta: float) -> void:
	if camera:
		camera.rotation.z = lerpf(camera.rotation.z, -input_vector.x / 10, 10 * delta)

func weapon_sway(delta: float) -> void:
	if weapon_pivot:
		weapon_pivot.rotation.x = lerpf(weapon_pivot.rotation.x, WEAPON_SWAY_AMOUNT * mouse_movement.y, 1.0 - pow(1.0 - WEAPON_SWAY_SPEED, delta))
		weapon_pivot.rotation.y = lerpf(weapon_pivot.rotation.y, WEAPON_SWAY_AMOUNT * mouse_movement.x, 1.0 - pow(1.0 - WEAPON_SWAY_SPEED, delta))

func change_effect():
	animation.play("fade")
	change_scene = false

func knock_back(dir: Vector3, force: float, duration: float):
	knockback = dir * force
	knock_timer = duration

func knock_back_apply(delta: float):
	velocity = knockback
	knock_timer -= delta


# ===================
# HEALTH & AMMO LOGIC
# ===================
func take_damage(amount: int) -> void:
	if change_scene == false:
		print("Player HP: ", health)
		if health >= 10 and health - amount != 0:
			health -= amount
			HUD.instance.display_health(health)
		else: 
			
			change_scene = true
			await get_tree().create_timer(2).timeout
			get_tree().reload_current_scene()
			
func launch_bullet(bullet: PlayerBullet, launch_position: Vector3, launch_direction: Vector3, launch_speed: float) -> void:
	bullet.linear_velocity = launch_direction * launch_speed
	bullet.position = get_parent().to_local(launch_position)
	bullet.add_collision_exception_with(self)
	get_parent().add_child(bullet)

func shoot() -> void:
	if is_reloading:
		return
	if ammo > 0:
		launch_bullet(preload("res://Scenes/player_bullet.tscn").instantiate(), shoot_point.global_position, -shoot_point.global_transform.basis[2].normalized(), 75.0)
		ammo -= 1
		print("Bang! Ammo left:", ammo)
		update_ammo_ui()
	else:
		print("No ammo! Press reload.")

func start_reload() -> void:
	if ammo == reload_ammount or max_ammo == 0:
		return
	
	is_reloading = true
	print("Reloading...")
	await get_tree().create_timer(reload_time).timeout
	
	var empty_space = reload_ammount - ammo
	var how_much: int = min(empty_space, max_ammo)
	
	ammo += how_much
	max_ammo -= how_much
	
	is_reloading = false
	update_ammo_ui()
	
# Hud UPDATES 
func update_ammo_ui():
	HUD.instance.display_ammo(ammo, max_ammo)
 
