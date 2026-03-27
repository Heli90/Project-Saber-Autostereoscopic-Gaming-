extends Node3D
class_name OQ_UI2DKeyboard

# if 'show_text_input' is enabled and this flag is set true, then
# the text input box will aquire focus when then keyboard gains visibilty
@export var focus_on_visible := false
@export var cancelable := true
# the minimum number of characters needed to be entered before the enter button
# will be enabled
@export var min_chars_to_enable_enter := 0

# if 'true' then the keyboard will make sure the first letter of each word is
# capitalized
@export var is_name_input := false

# due to how OQ_UI2DCanvas moves items around the scene tree,
# a regular path $Like/This returns null
@onready var _text_edit := $OQ_UI2DCanvas_TextInput.find_child("TextEdit", true, false) as TextEdit
@onready var _keyboard := $OQ_UI2DCanvas_Keyboard.find_child("VirtualKeyboard", true, false) as VirtualKeyboard

signal text_input_cancel()
signal text_input_enter(text: String)


func _on_cancel() -> void:
	@warning_ignore("return_value_discarded")
	emit_signal("text_input_cancel")
	_text_edit.text = ""


func _on_enter() -> void:
	@warning_ignore("return_value_discarded")
	emit_signal("text_input_enter", _text_edit.text)
	_text_edit.text = ""


func _ready() -> void:
	#_text_edit = $OQ_UI2DCanvas_TextInput.find_child("TextEdit", true, false) as TextEdit
	#_keyboard = $OQ_UI2DCanvas_Keyboard.find_child("VirtualKeyboard", true, false) as VirtualKeyboard
	_keyboard.set_cancelable(cancelable)
	
	# force update of things that based on the text input
	#  * enable/disable enter key based on min char length
	#  * name input capitalization
	_on_TextEdit_text_changed()
	
	_text_edit.grab_focus()

func _show() -> void:
	visible = true
	_text_edit.grab_focus()
	
func _hide() -> void:
	visible = false

func _on_TextEdit_text_changed() -> void:
	var text_len := _text_edit.text.length()
	var disable_enter := text_len < min_chars_to_enable_enter
	_keyboard.enter_button_disabled(disable_enter)
	
	if is_name_input:
		# default first letter of each 'word' to a capital
		var upper_case := text_len == 0
		if text_len > 0:
			upper_case = _text_edit.text[-1] == ' '
		_keyboard.set_upper_case(upper_case)
