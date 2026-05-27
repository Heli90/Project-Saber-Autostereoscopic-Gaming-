extends Control

@onready var bar_filled: ColorRect = $BarFilled
@onready var heart_label: Label = $HeartLabel

const MAX_PV = 10

func update_health(new_health_value: int) -> void:
	heart_label.text = str(10 * new_health_value)
	var target_ratio = float(new_health_value)/float(MAX_PV)
	var transition = create_tween()
	transition.tween_property(bar_filled, "scale:x", target_ratio, 0.3)
