extends Node

@export var scroll_node_path: NodePath
var scroll_node: Control
var v_scroll: VScrollBar
var is_mouse_in := false
var relpos := 0.0
var scrollpos := 0.0

# JOYSTICK_SCROLL_THRESHOLD
# Range: 0.0 to 1.0
# Description: Scrolling via the joystick is engadged when the absolute value
# of the joystick's position exceeds this threshold. This prevents accidental
# scroll events occuring from small amounts of noise/movements in the joystick.
const JOYSTICK_SCROLL_THRESHOLD := 0.1

# JOYSTICK_SLOW_SCROLL_SPEED
# Range: 0 to max
# Description: The minimum scroll speed to use when scrolling via the joystick.
# This value is interpolated against the joystick's position and represents the
# scrolling speed nearest to the joystick's resting position.
const JOYSTICK_SLOW_SCROLL_SPEED := 10.0

# JOYSTICK_FAST_SCROLL_SPEED
# Range: 0 to max
# Description: The maximum scroll speed to use when scrolling via the joystick.
# This value is interpolated against the joystick's position and represents the
# scrolling speed at full throw of the joystick.
const JOYSTICK_FAST_SCROLL_SPEED := 2000.0

func _ready() -> void:
	scroll_node = get_node(scroll_node_path) as Control
	
	if scroll_node is ItemList:
		v_scroll = (scroll_node as ItemList).get_v_scroll_bar()
	elif scroll_node is ScrollContainer:
		v_scroll = (scroll_node as ScrollContainer).get_v_scroll_bar()
	
	@warning_ignore("return_value_discarded")
	scroll_node.connect(&"mouse_entered", Callable(self, &"_mouse_entered"))
	@warning_ignore("return_value_discarded")
	scroll_node.connect(&"mouse_exited", Callable(self, &"_mouse_exited"))

func _process(delta: float) -> void:
	var newpos := -vr.rightController.rotation_degrees.x - (vr.rightController.transform.origin.y * 20.0)
	if is_mouse_in:
		if vr.rightController.trigger_pressed():
			# Scroll via "click & drag"
			v_scroll.value += ((relpos - newpos) * 20.0)
		else:
			# Scroll via joystick
			var y_joy := vr.rightController.get_vector2("primary").y
			if absf(y_joy) > JOYSTICK_SCROLL_THRESHOLD:
				# negate sign so positive scroll_amounts will scroll down
				var scroll_amount := lerpf(
					JOYSTICK_SLOW_SCROLL_SPEED,
					JOYSTICK_FAST_SCROLL_SPEED,
					absf(y_joy)) * -signf(y_joy) * delta
				v_scroll.value += scroll_amount
	relpos = newpos

func _mouse_entered() -> void:
	is_mouse_in = true

func _mouse_exited() -> void:
	is_mouse_in = false
