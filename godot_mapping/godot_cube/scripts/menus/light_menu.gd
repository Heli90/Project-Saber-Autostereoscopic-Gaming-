extends DirectionalLight2D

@export var intensite_min: float = 0.2
@export var intensite_max: float = 1.5
@export var vitesse: float = 0.1
var temps: float = 0.0

func _process(delta: float) -> void:
	temps += delta * vitesse
	var oscillation = (sin(temps) + 1.0) / 2.0
	energy = lerp(intensite_min, intensite_max, oscillation)
