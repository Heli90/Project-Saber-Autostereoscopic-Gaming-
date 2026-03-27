extends DefaultSaber

@onready var particles := $CPUParticles3D as CPUParticles3D

func _sub_ready() -> void:
	if OS.get_name() in ["Android","Web"]:
		particles.free()

var last_tip_pos := Vector3.ZERO

func _process(_delta: float) -> void:
	var current_tip_pos := tip.global_transform.origin
	var speed := (current_tip_pos-last_tip_pos).length()
	if is_instance_valid(particles):
		particles.speed_scale = 2.5+(30*speed)
		#Particles.lifetime = max(0.1, 2-(20*speed))
	last_tip_pos = current_tip_pos

func hit(time_offset: float) -> void:
	super(time_offset)
	hitsound.pitch_scale = randf_range(0.9,1.1)

func set_thickness(_value: float) -> void: #ignore set thinkness on this saber
	pass
