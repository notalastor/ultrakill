extends CPUParticles3D

@export var node_lifetime_override: float = -1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = true
	for c: Node in get_children():
		if c is CPUParticles3D:
			c.emitting = true

	var node_lifetime: float = node_lifetime_override
	if node_lifetime < 0.0:
		node_lifetime = ((2.0 - explosiveness) * lifetime) / speed_scale
	get_tree().create_timer(node_lifetime, false).timeout.connect(queue_free)
