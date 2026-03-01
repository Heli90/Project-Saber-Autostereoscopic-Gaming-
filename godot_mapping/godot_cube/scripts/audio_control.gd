extends HSlider

@export var audio_bus_name: String
var audio_bus_id

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

func _onValueChanged(sound_value: float) -> void:
	var db = linear_to_db(sound_value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
