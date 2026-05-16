extends Control

@onready var bar_filled: ColorRect = $BarFilled
@onready var shield_label: Label = $ShieldLabel

const MAX_SHIELD = 5

func update_shield(new_shield_value: int) -> void:
	shield_label.text = str(20 * new_shield_value)
	var target_ratio = float(new_shield_value)/float(MAX_SHIELD)
	var transition = create_tween()
	transition.tween_property(bar_filled, "scale:x", target_ratio, 0.3)
