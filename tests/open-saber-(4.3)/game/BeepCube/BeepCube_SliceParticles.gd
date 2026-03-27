extends Node3D
class_name BeepCubeSliceParticles

@onready var c1 := $Particles3D as GPUParticles3D

func _ready() -> void:
	c1.one_shot = true
	#disable gpu particles since they don't work correctly on android
	if OS.get_name() in ["Android","Web"]:
		c1.free()
	reset()

func reset() -> void:
	if not c1: return
	visible = false
	c1.emitting = false
	c1.restart()

func fire() -> void:
	if not c1: return
	visible = true
	c1.emitting = true
