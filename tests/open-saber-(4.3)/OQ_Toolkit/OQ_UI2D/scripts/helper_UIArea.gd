# A Helper to make UIs work on a Area object
extends UIRaycastTarget

# Member variables
@onready var parent := get_parent() as OQ_UI2DCanvas
@onready var viewport := parent.get_node("SubViewport") as SubViewport

var last_pos2d := Vector2(INF, INF)


func ui_raycast_hit_event(pos: Vector3, click: bool, release: bool) -> void:
	# note: this transform assumes that the unscaled area is [-0.5, -0.5] to [0.5, 0.5] in size
	var local_position := to_local(pos)
	var pos2d := Vector2(local_position.x, -local_position.y)
	pos2d = pos2d + Vector2(0.5, 0.5)
	pos2d.x *= viewport.size.x
	pos2d.y *= viewport.size.y
	
	if (click || release):
		var e := InputEventMouseButton.new()
		e.pressed = click
		e.button_index = MOUSE_BUTTON_LEFT
		e.position = pos2d
		e.global_position = pos2d
		
		viewport.push_input(e)
		parent._input_update()
	elif (last_pos2d != Vector2(INF, INF) && last_pos2d != pos2d):
		var e := InputEventMouseMotion.new()
		e.relative = pos2d - last_pos2d
		e.velocity = (pos2d - last_pos2d) / 16.0 #?? chose an arbitrary scale here for now
		e.global_position = pos2d
		e.position = pos2d
		
		viewport.push_input(e)
		parent._input_update()
	last_pos2d = pos2d
