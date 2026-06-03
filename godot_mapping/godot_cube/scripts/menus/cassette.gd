extends TextureButton

const SCALE_FACTOR: float = 1.15
const SCALE_DURATION: float = 0.2
const ANGLE_DEG: float = 25.0
const ROTATION_DURATION: float = 0.25

var scale_transition: Tween
var loop_rotation_transition: Tween
var first_rotation_transition: Tween
var base_scale: Vector2

func _ready() -> void:
	await get_tree().process_frame
	base_scale = scale
	mouse_entered.connect(_onHoverEnter)
	mouse_exited.connect(_onHoverExit)

func _onHoverEnter() -> void:
	if scale_transition: scale_transition.kill()
	if first_rotation_transition: first_rotation_transition.kill()
	if loop_rotation_transition: loop_rotation_transition.kill()

	scale_transition = create_tween()
	scale_transition.set_ease(Tween.EASE_OUT)
	scale_transition.set_trans(Tween.TRANS_BACK)
	scale_transition.tween_property(self, "scale", base_scale * SCALE_FACTOR, SCALE_DURATION)
	await scale_transition.finished
	
	first_rotation_transition = create_tween()
	first_rotation_transition.set_ease(Tween.EASE_IN_OUT)
	first_rotation_transition.set_trans(Tween.TRANS_SINE)
	first_rotation_transition.tween_property(self, "rotation_degrees", ANGLE_DEG, ROTATION_DURATION)
	await first_rotation_transition.finished

	loop_rotation_transition = create_tween().set_loops()
	loop_rotation_transition.set_ease(Tween.EASE_IN_OUT)
	loop_rotation_transition.set_trans(Tween.TRANS_SINE)
	loop_rotation_transition.tween_property(self, "rotation_degrees", -ANGLE_DEG, ROTATION_DURATION * 2)
	loop_rotation_transition.tween_property(self, "rotation_degrees", ANGLE_DEG, ROTATION_DURATION * 2)

func _onHoverExit() -> void:
	if scale_transition: scale_transition.kill()
	if first_rotation_transition: first_rotation_transition.kill()
	if loop_rotation_transition: loop_rotation_transition.kill()

	var out = create_tween()
	out.set_ease(Tween.EASE_OUT)
	out.set_trans(Tween.TRANS_SINE)
	out.set_parallel(true)
	out.tween_property(self, "scale", base_scale, SCALE_DURATION)
	out.tween_property(self, "rotation_degrees", 0.0, SCALE_DURATION)
