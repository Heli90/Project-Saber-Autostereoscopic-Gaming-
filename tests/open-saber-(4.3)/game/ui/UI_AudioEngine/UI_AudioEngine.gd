extends Node

@onready var hover_stream := $HoverStream as AudioStreamPlayer
@onready var click_stream := $ClickStream as AudioStreamPlayer

func attach_children(node: Node, include_buttons: bool = true, include_texture_buttons: bool = true) -> void:
	for child in node.get_children():
		if include_buttons and child is Button:
			attach_button(child as Button)
		elif include_texture_buttons and child is TextureButton:
			attach_button(child as TextureButton)
		
		attach_children(child, include_buttons)

func attach_button(button: BaseButton) -> void:
	@warning_ignore("return_value_discarded")
	button.mouse_entered.connect(_on_button_hovered.bind(button))
	@warning_ignore("return_value_discarded")
	button.pressed.connect(_on_button_pressed)

func play_click() -> void:
	click_stream.play()
	
func set_volume(value_db: float) -> void:
	var bus_idx := AudioServer.get_bus_index(&"UI")
	AudioServer.set_bus_volume_db(bus_idx, value_db)

# prevent spuratic clicking when mouse enters/exits a control quickly
const HOVER_DEBOUNCE_TIME_MS = 200
var _prev_hovered_ctrl: BaseButton
var _prev_hover_time := 0
func _on_button_hovered(control: BaseButton) -> void:
	# prevent rapid hover sound effects that can occur when the mouse is
	# very close to the edge of the control node (ie. enters/exists quickly)
	var time_now_ms := Time.get_ticks_msec()
	if _prev_hovered_ctrl != control or (time_now_ms - _prev_hover_time) > HOVER_DEBOUNCE_TIME_MS:
		hover_stream.play()
	
	_prev_hovered_ctrl = control
	_prev_hover_time = time_now_ms

func _on_button_pressed() -> void:
	click_stream.play()
