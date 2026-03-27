extends Node3D

@export var autoremove_distance := 2.0

func set_notificaiton_text(title: String, text: String) -> void:
	var text_label := $OQ_UI2DCanvas.find_child("NotificationText_Label", true, false) as Label
	var title_label := $OQ_UI2DCanvas.find_child("Title_Label", true, false) as Label
	text_label.set_text(text)
	title_label.set_text(title)

func _remove_notification_window() -> void:
	get_parent().remove_child(self)
	queue_free()

func _physics_process(_dt: float) -> void:
	if (vr.leftController.ax_just_pressed()
		or vr.rightController.ax_just_pressed()):
		_remove_notification_window()
	elif autoremove_distance > 0 && (global_transform.origin - vr.vrCamera.global_transform.origin).length() > autoremove_distance:
		_remove_notification_window()
