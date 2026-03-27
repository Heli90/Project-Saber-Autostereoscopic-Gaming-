extends Panel
class_name VirtualKeyboard


@onready var _reference_button := $ReferenceButton as Button
@onready var _container_letters := $Container_Letters as Container
@onready var _container_symbols := $Container_Symbols as Container

@export var allow_newline := false

const B_SIZE := 48

var NUMBER_LAYOUT := PackedStringArray(["1","2","3","4","5","6","7","8","9","0"])

var BUTTON_LAYOUT_ENGLISH: Array[PackedStringArray] = [
	PackedStringArray(["q","w","e","r","t","y","u","i","o","p"]),
	PackedStringArray(["a","s","d","f","g","h","j","k","l",":"]),
	PackedStringArray(["@","z","x","c","v","b","n","m","!","."]),
	PackedStringArray(["/"])
]

var BUTTON_LAYOUT_SYMBOLS: Array[PackedStringArray] = [
	PackedStringArray(["!","@","#","$","%","^","&","*","(",")"]),
	PackedStringArray([".",'"',"'",",","-","?",":",";","{","}"]),
	PackedStringArray(["+","_","=","|","/","\\","<",">","[","]"])
]


signal enter_pressed
signal cancel_pressed


var _all_letter_buttons: Array[Button] = []

func _toggle_symbols(show_symbols: bool) -> void:
	_container_letters.visible = not show_symbols
	_container_symbols.visible = show_symbols

func _create_input_event(b: Button, pressed: bool) -> InputEventKey:
	var keycode := KEY_NONE
	var key := b.text
	var unicode := 0

	if (b == _toggle_symbols_button):
		_toggle_symbols(b.button_pressed)
		return
	elif (b == _cancel_button):
		if (!pressed): cancel_pressed.emit()
		return
	elif (b == _shift_button):
		if (pressed): 
			set_upper_case(!b.button_pressed) # button event is created before it is actually toggled
		keycode = KEY_SHIFT
	elif (b == _backspace_button):
		keycode = KEY_BACKSPACE
	elif (b == _enter_button):
		keycode = KEY_ENTER
		if (!pressed): enter_pressed.emit()
		if (!allow_newline): return # no key event for enter in this case
	elif (b == _space_button):
		keycode = KEY_SPACE
		key = " "
		unicode = " ".unicode_at(0)
	else:
		keycode = OS.find_keycode_from_string(b.text)
		unicode = key.unicode_at(0)
	

	#print("  Event for " + key + ": scancode = " + str(scancode));
	
	var ev := InputEventKey.new();
	ev.keycode = keycode
	ev.unicode = unicode
	ev.pressed = pressed

	return ev;


# not sure what causes this yet but it happens that a button press
# triggers twice the down without up
var _last_button_down_hack: Button

func _on_button_down(b: Button) -> void:
	if (b == _last_button_down_hack): return
	_last_button_down_hack = b
	
	var ev := _create_input_event(b, true)
	if (!ev): return
	Input.parse_input_event(ev)


func _on_button_up(b: Button) -> void:
	_last_button_down_hack = null
	
	var ev := _create_input_event(b, false)
	if (!ev): return
	Input.parse_input_event(ev)


func _create_button(parent: Node, text: String, x: float, y: float, w: float = 1.0, h: float = 1.0) -> Button:
	var b := _reference_button.duplicate() as Button
	b.text = text
	
	if (b.text.length() == 1):
		var c := b.text.unicode_at(0)
		if (c >= 97 && c <= 122):
			_all_letter_buttons.append(b)
	
	b.position = Vector2(x, y) * B_SIZE
	b.custom_minimum_size = Vector2(w, h) * B_SIZE
	
	b.name = "button_"+text
	
	@warning_ignore("return_value_discarded")
	b.button_down.connect(_on_button_down.bind(b))
	@warning_ignore("return_value_discarded")
	b.button_up.connect(_on_button_up.bind(b))
	
	parent.add_child(b)
	return b

var _toggle_symbols_button: Button
var _shift_button: Button
var _backspace_button: Button
var _enter_button: Button
var _space_button: Button
var _cancel_button: Button

func _create_keyboard_buttons() -> void:
	_toggle_symbols_button = _create_button(self, "#$%", 0+1, 1, 2, 1)
	_toggle_symbols_button.set_rotation(deg_to_rad(90.0))
	_toggle_symbols_button.toggle_mode = true
	
	_shift_button = _create_button(self, "Δ", 0, 3, 1, 2)
	_shift_button.toggle_mode = true
	
	_backspace_button = _create_button(self, "BckSp.", 11+1, 1, 2, 1)
	_backspace_button.set_rotation(deg_to_rad(90.0))
	_enter_button = _create_button(self, "Enter", 11+1, 3, 2, 1)
	_enter_button.set_rotation(deg_to_rad(90.0))
	
	_space_button = _create_button(self, "Space", 2, 4, 9, 1)

	_cancel_button = _create_button(self, "X", 11, 0, 1, 1)
	
	var x := 1.0
	var y := 0.0
	
	for k in NUMBER_LAYOUT:
		@warning_ignore("return_value_discarded")
		_create_button(self, k, x, y)
		x += 1.0
	
	x = 1.0
	y = 1.0
	# standard buttons
	for line in BUTTON_LAYOUT_ENGLISH:
		for k in line:
			@warning_ignore("return_value_discarded")
			_create_button(_container_letters, k, x, y)
			x += 1.0
		y += 1.0
		x = 1.0
	
	x = 1.0
	y = 1.0
	# standard buttons
	for line in BUTTON_LAYOUT_SYMBOLS:
		for k in line:
			@warning_ignore("return_value_discarded")
			_create_button(_container_symbols, k, x, y)
			x += 1.0
		y += 1.0
		x = 1.0
	
	_reference_button.visible = false
	_toggle_symbols(_toggle_symbols_button.button_pressed)

func set_cancelable(cancelable: bool) -> void:
	if _cancel_button != null:
		_cancel_button.visible = cancelable

func enter_button_disabled(disabled: bool) -> void:
	if _enter_button != null:
		_enter_button.disabled = disabled
		
func set_upper_case(upper_case: bool) -> void:
	if (upper_case):
		for b in _all_letter_buttons:
			b.text = b.text.to_upper()
	else:
		for b in _all_letter_buttons:
			b.text = b.text.to_lower()

func _ready() -> void:
	_create_keyboard_buttons()
	_toggle_symbols(false)
