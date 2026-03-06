extends HSlider

@export var audio_bus_name: String
var audioBusId

func _ready():
	audioBusId = AudioServer.get_bus_index(audio_bus_name)
	var v_db = AudioServer.get_bus_volume_db(audioBusId)
	value = db_to_linear(v_db)

func _onValueChanged(sound_value: float) -> void:
	var db = linear_to_db(sound_value)
	AudioServer.set_bus_volume_db(audioBusId, db)
