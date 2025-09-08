class_name HUD
extends CanvasLayer


@onready var ammo_curr_amount_label: Label = $Anchor/ProgressBars/HBoxContainer2/Bullet/HBoxContainer/CurrentAmount
@onready var ammo_max_amount_label: Label = $Anchor/ProgressBars/HBoxContainer2/Bullet/HBoxContainer/Amount
@onready var health_bar: ProgressBar = $Anchor/ProgressBars/HBoxContainer2/VBoxContainer/HealthBar

static var instance: HUD


func _ready() -> void:
	HUD.instance = self

func display_ammo(current_ammo: int, max_ammo: int) -> void:
	ammo_curr_amount_label.text = str(current_ammo)
	ammo_max_amount_label.text = str(max_ammo)

func display_health(health: float) -> void:
	health_bar.value = health
