extends TextureButton

@export var direction: int = 1

const SCALE_FACTOR: float = 1.05
const SCALE_DURATION: float = 0.4
const ANGLE_DEG: float = 25.0
const ROTATION_DURATION: float = 0.25

var first_scale_transition: Tween
var loop_scale_transition: Tween
var base_scale: Vector2

func _ready() -> void:
	await get_tree().process_frame
	base_scale = scale

func _onMouseEnter() -> void:
	if first_scale_transition: first_scale_transition.kill()
	if loop_scale_transition: loop_scale_transition.kill()

	first_scale_transition = create_tween()
	first_scale_transition.set_ease(Tween.EASE_OUT)
	first_scale_transition.set_trans(Tween.TRANS_BACK)
	first_scale_transition.tween_property(self, "scale", base_scale * SCALE_FACTOR, SCALE_DURATION)
	await first_scale_transition.finished
	
	loop_scale_transition = create_tween().set_loops()
	loop_scale_transition.set_ease(Tween.EASE_OUT)
	loop_scale_transition.set_trans(Tween.TRANS_BACK)
	loop_scale_transition.tween_property(self, "scale", base_scale / (SCALE_FACTOR ** 2), SCALE_DURATION / 2)
	loop_scale_transition.tween_property(self, "scale", base_scale * (SCALE_FACTOR ** 2), SCALE_DURATION * 2)

func _onMouseExit() -> void:
	if first_scale_transition: first_scale_transition.kill()
	if loop_scale_transition: loop_scale_transition.kill()

	var out = create_tween()
	out.set_ease(Tween.EASE_OUT)
	out.set_trans(Tween.TRANS_SINE)
	out.set_parallel(true)
	out.tween_property(self, "scale", base_scale, SCALE_DURATION)
