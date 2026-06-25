extends CanvasLayer

@onready var score : Label = $ScoresPanel/VBoxContainer/Score
@onready var gain_score  : Label = $ScoresPanel/GainScore
@export var player_id = 1
var displayed_score : int = 0

func ajouter_score(gain: int) -> void:
	displayed_score += gain
	if player_id == 1 :
		displayed_score += floor((Global.bonus_z_j1_l + Global.bonus_z_j1_r)/2.0)
	if player_id == 2:
		displayed_score += floor((Global.bonus_z_j2_l + Global.bonus_z_j2_r)/2.0)
	score.text = str(displayed_score)
	afficher_gain(gain)

func afficher_gain(gain: int) -> void:
	var bonus_z : float
	if player_id == 1 :
		bonus_z = (Global.bonus_z_j1_l+Global.bonus_z_j1_r)/2
	if player_id == 2:
		bonus_z = (Global.bonus_z_j2_l+Global.bonus_z_j2_r)/2
	gain += floor(bonus_z)
	if gain > 0 : gain_score.text = "+%d" % gain
	else : gain_score.text = "-%d" % (-gain)
	gain_score.modulate.a = 1.0
	gain_score.visible = true

	var transition = create_tween()
	transition.tween_interval(0.7)
	transition.tween_property(gain_score, "modulate:a", 0.0, 0.3)
	await transition.finished
	gain_score.visible = false
