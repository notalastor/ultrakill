class_name HUD
extends CanvasLayer


@onready var ammo_curr_amount_label: Label = $Anchor/ProgressBars/HBoxContainer2/Bullet/HBoxContainer/CurrentAmount
@onready var ammo_max_amount_label: Label = $Anchor/ProgressBars/HBoxContainer2/Bullet/HBoxContainer/Amount
@onready var health_bar: ProgressBar = $Anchor/ProgressBars/HBoxContainer2/VBoxContainer/HealthBar
@onready var damage_effect_animation_player: AnimationPlayer = %DamageEffectAnimation # Use unique names for ui nodes, since its scene tree structure is more prone to change than its functionality

static var instance: HUD

func display_damage_effect() -> void:
	damage_effect_animation_player.play(&"effect")

func _ready() -> void:
	HUD.instance = self

func display_ammo(current_ammo: int, max_ammo: int) -> void:
	ammo_curr_amount_label.text = str(current_ammo)
	ammo_max_amount_label.text = str(max_ammo)

func display_health(health: float) -> void:
	health_bar.value = health

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE and !event.echo:
			if !get_tree().paused:
				add_child( preload("res://Scenes/pause_menu.tscn").instantiate())
				get_tree().paused = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
