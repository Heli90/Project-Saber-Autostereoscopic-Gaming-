extends CSGBox3D

var vitesse_deplacement: float = 1.0

func _process(delta: float) -> void:
	rotation.z += vitesse_deplacement * delta
