extends CharacterBody3D


@export var SPEED: float = 5.0 ## سرعة العدو
@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@export var target: Node3D ##الهدف اللازم ملاحقته
@export var min_distance = 1.5 ##المسافه بين العدو و اللاعب, يتحرك العدو اذا كان البعد بينهما اكبر من هذه القيمه
@export var min_shooter_distance = 20
@export var force: float = 15.0 ##قوة/ بعد الضربة 
@export var knock_time: float = 0.2 ##المدة اللازمه لتوقف تأثير الضربه
@export var shooter: bool
func _ready() -> void:
	if shooter:
		$Timer.autostart = true
		$Timer.start()

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	look_at(Vector3(target.global_position.x,global_position.y,target.global_position.z))
	navigation.target_position = target.global_position
	var distance_to_player = global_position.distance_to(target.global_position)
	if not shooter:
		if distance_to_player > min_distance:
			var next_position = navigation.get_next_path_position()
			var direction = (next_position - global_position).normalized()
			velocity = direction * SPEED
			move_and_slide()
		else:
			velocity = Vector3.ZERO
	else:
		if distance_to_player > min_shooter_distance:
			var next_position = navigation.get_next_path_position()
			var direction = (next_position - global_position).normalized()
			velocity = direction * SPEED
			move_and_slide()
		else:
			velocity = Vector3.ZERO


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		var knock_dir = (body.global_position - global_position).normalized()
		knock_dir.y /= 2
		body.knock_back(knock_dir,force,knock_time)

@onready var shoot: Marker3D = $shoot

func _on_timer_timeout() -> void:
	shoot.look_at(target.position)
	var fire = preload("res://Scenes/fireball.tscn").instantiate()
	fire.position = shoot.global_position
	fire.transform.basis = shoot.global_transform.basis
	get_parent().add_child(fire)
