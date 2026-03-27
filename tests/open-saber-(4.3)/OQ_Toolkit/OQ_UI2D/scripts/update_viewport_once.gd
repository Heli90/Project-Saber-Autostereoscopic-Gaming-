extends Node
class_name UpdateViewport

func update_once(_viewport: SubViewport) -> void:
	#manually disable update since godot doesn't seems to do it automatically with UPDATE_ONCE (in 4.2-dev4)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.set_meta("frames_since_last_update", 0)
	await get_tree().process_frame
	_viewport.set_meta("frames_since_last_update", _viewport.get_meta("frames_since_last_update") + 1)
	await get_tree().process_frame
	_viewport.set_meta("frames_since_last_update", _viewport.get_meta("frames_since_last_update") + 1)
	await get_tree().process_frame
	if _viewport.get_meta("frames_since_last_update") >= 2:
		_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
