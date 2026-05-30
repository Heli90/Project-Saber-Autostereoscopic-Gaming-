extends TextureButton

@export var direction: int = 1

const SCALE_FACTOR = 1.15
const SCALE_DURATION = 0.2
const ANGLE_DEG = 25.0
const ROTATION_DURATION = 0.25

var scale_transition: Tween
var base_scale: Vector2

func _ready() -> void:
	await get_tree().process_frame
	base_scale = scale
	mouse_entered.connect(_onHoverEnter)
	mouse_exited.connect(_onHoverExit)

func _onHoverEnter() -> void:
	if scale_transition: scale_transition.kill()

	scale_transition = create_tween()
	scale_transition.set_ease(Tween.EASE_OUT)
	scale_transition.set_trans(Tween.TRANS_BACK)
	scale_transition.tween_property(self, "scale", base_scale * SCALE_FACTOR, SCALE_DURATION)
	await scale_transition.finished

func _onHoverExit() -> void:
	if scale_transition: scale_transition.kill()

	var out = create_tween()
	out.set_ease(Tween.EASE_OUT)
	out.set_trans(Tween.TRANS_SINE)
	out.set_parallel(true)
	out.tween_property(self, "scale", base_scale, SCALE_DURATION)
