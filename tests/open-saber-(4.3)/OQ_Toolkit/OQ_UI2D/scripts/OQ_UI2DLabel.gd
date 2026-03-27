@tool
extends Node3D
class_name OQ_UI2DLabel

@export var text := "I am a Label\nWith a new line"
@export var margin := 16;
@export var billboard := false
@export var depth_test := true

enum ResizeModes {AUTO_RESIZE, FIXED}
@export var resize_mode := ResizeModes.AUTO_RESIZE

@export var font_size_multiplier := 1.0
@export var font_color := Color(1,1,1,1)
@export var background_color := Color(0,0,0,1)

@export var transparent := false

func set_transparent(value: bool) -> void:
	transparent = value
	mesh_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if transparent else BaseMaterial3D.TRANSPARENCY_DISABLED


@onready var ui_label := $SubViewport/ColorRect/CenterContainer/Label as Label
@onready var ui_container := $SubViewport/ColorRect/CenterContainer as CenterContainer
@onready var ui_color_rect := $SubViewport/ColorRect as ColorRect
@onready var ui_viewport := $SubViewport as SubViewport
@onready var mesh_instance := $MeshInstance3D as MeshInstance3D
var ui_mesh: QuadMesh

var mesh_material: StandardMaterial3D

func _ready() -> void:
	ui_mesh = mesh_instance.mesh as QuadMesh
	set_label_text(text)
	
	mesh_material = mesh_instance.material_override as StandardMaterial3D
	mesh_material.albedo_texture = ui_viewport.get_texture()
	
	if (billboard):
		mesh_material.billboard_mode = StandardMaterial3D.BILLBOARD_FIXED_Y
	mesh_material.no_depth_test = !depth_test
	
	# only enable transparency when necessary as it is significantly slower than non-transparent rendering
	set_transparent(transparent)
	
	ui_label.add_theme_color_override("font_color", font_color)
	ui_color_rect.color = background_color


func resize_auto() -> void:
	var size := ui_label.get_minimum_size()
	var res := Vector2(size.x + margin * 2, size.y + margin * 2)
	
	ui_container.set_size(res)
	ui_viewport.set_size(res)
	ui_color_rect.set_size(res)
	
	ui_mesh.size.x = font_size_multiplier * res.x * vr.UI_PIXELS_TO_METER
	ui_mesh.size.y = font_size_multiplier * res.y * vr.UI_PIXELS_TO_METER


func resize_fixed() -> void:
	# resize container and viewport while parent and mesh stay fixed
	
	var parent_width := scale.x
	var parent_height := scale.y
	
	var new_size := Vector2(parent_width * 1024 / font_size_multiplier, parent_height * 1024 / font_size_multiplier)
	
	ui_viewport.set_size(new_size)
	ui_color_rect.set_size(new_size)
	ui_container.set_size(new_size)

func get_label_text() -> String:
	return ui_label.text

func set_label_text(t: String) -> void:
	ui_label.set_text(t)
	
	match resize_mode:
		ResizeModes.AUTO_RESIZE:
			resize_auto()
		ResizeModes.FIXED:
			resize_fixed()
	if !Engine.is_editor_hint():
		($update_once as UpdateViewport).update_once(ui_viewport)

func _process(_dt: float) -> void:
	if Engine.is_editor_hint():
		set_label_text(text)
