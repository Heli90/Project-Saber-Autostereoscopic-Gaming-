extends AnimatableBody3D

var appui_touche11 = false;
var appui_touche12 = false;
var appui_touche21 = false;
var appui_touche22 = false;

var speed = 5.0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if appui_touche11 :
		rotate_y(speed*delta);
	if appui_touche12 :
		rotate_y(-speed*delta);
	if appui_touche21 :
		rotate_x(speed*delta);
	if appui_touche22 :
		rotate_x(-speed*delta);

func _input(event) -> void:
	if event.is_action_pressed("Rotation11"):
		appui_touche11 = true;
	if event.is_action_released("Rotation11"):
		appui_touche11 = false;
	if event.is_action_pressed("Rotation12"):
		appui_touche12 = true;
	if event.is_action_released("Rotation12"):
		appui_touche12 = false;
	if event.is_action_pressed("Rotation21"):
		appui_touche21 = true;
	if event.is_action_released("Rotation21"):
		appui_touche21 = false;
	if event.is_action_pressed("Rotation22"):
		appui_touche22 = true;
	if event.is_action_released("Rotation22"):
		appui_touche22 = false;	
		
