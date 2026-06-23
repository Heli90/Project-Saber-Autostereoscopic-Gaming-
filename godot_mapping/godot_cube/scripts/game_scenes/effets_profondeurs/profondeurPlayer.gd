extends Node
class_name ProfondeurPlayer

@export var scene_camera : Node

var base_convergence : float
var effets_actifs : Array[ProfondeurEffet]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_convergence = scene_camera.convergence_distance
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if effets_actifs.is_empty(): return
	
	var convergence_delta = 0.0
	
