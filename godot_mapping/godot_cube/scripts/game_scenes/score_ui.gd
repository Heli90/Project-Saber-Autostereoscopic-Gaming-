extends CanvasLayer

@onready var score : Label = $ScoresPanel/VBoxContainer/Score
@onready var gain_score  : Label = $ScoresPanel/GainScore
var displayed_score : int = 0

func ajouter_score(gain: int) -> void:
	displayed_score += gain
	score.text = str(displayed_score)
	afficher_gain(gain)

func afficher_gain(gain: int) -> void:
	if gain > 0 : gain_score.text = "+%d" % gain
	else : gain_score.text = "-%d" % (-gain)
	gain_score.modulate.a = 1.0
	gain_score.visible = true

	var transition = create_tween()
	transition.tween_interval(0.7)
	transition.tween_property(gain_score, "modulate:a", 0.0, 0.3)
	await transition.finished
	gain_score.visible = false
