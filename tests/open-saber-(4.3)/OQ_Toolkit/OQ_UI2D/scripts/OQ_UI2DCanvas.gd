@tool
extends Node3D
class_name OQ_UI2DCanvas

var ui_control: Control

@onready var viewport := $SubViewport as SubViewport
@onready var ui_area := $UIArea as Area3D
var ui_collisionshape: CollisionShape3D

@export var editor_live_update := false

@export var transparency: BaseMaterial3D.Transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

# set to true to prevent UIRayCast marker from colliding with canvas
@export var disable_collision := false
@export var update_only_on_input := false

var mesh_material: StandardMaterial3D
@onready var mesh_instance := $UIArea/UIMeshInstance as MeshInstance3D


var ui_size := Vector2.ZERO

func _get_configuration_warnings() -> PackedStringArray:
	if (ui_control == null): return PackedStringArray(["Need a Control node as child."])
	return PackedStringArray()


func _input(event: InputEvent) -> void:
	if (event is InputEventKey):
		viewport.push_input(event)
		_input_update()


func find_child_control() -> void:
	ui_control = null
	for c in get_children():
		if c is Control:
			ui_control = c
			break

func update_size() -> void:
	ui_size = ui_control.get_size()
	if (ui_area != null):
		ui_area.scale.x = ui_size.x * vr.UI_PIXELS_TO_METER
		ui_area.scale.y = ui_size.y * vr.UI_PIXELS_TO_METER
	if (viewport != null):
		viewport.set_size(ui_size)

func _hide() -> void:
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	hide()

func _show() -> void:
	if !update_only_on_input:
		viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE
	else:
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		_input_update()
	show()

func _ready() -> void:
	mesh_material = mesh_instance.material_override as StandardMaterial3D
	mesh_material.albedo_texture = viewport.get_texture()
	# only enable transparency when necessary as it is significantly slower than non-transparent rendering
	mesh_material.transparency = transparency
	
	if Engine.is_editor_hint():
		return

	find_child_control()

	if (!ui_control):
		vr.log_warning("No UI Control element found in OQ_UI2DCanvas: %s" % get_path())
		return
	
	update_size()
	
	# reparent at runtime so we render to the viewport
	ui_control.get_parent().remove_child(ui_control)
	viewport.add_child(ui_control)
	ui_control.visible = true # set visible here as it might was set invisible for editing multiple controls
	
	ui_collisionshape = $UIArea/UICollisionShape as CollisionShape3D
	
	
func _editor_update_preview() -> void:
	var preview_node := ui_control.duplicate(DUPLICATE_USE_INSTANTIATION) as Control
	preview_node.visible = true
	
	for c in viewport.get_children():
		viewport.remove_child(c)
		c.queue_free()
	
	viewport.add_child(preview_node)

func _input_update() -> void:
	if update_only_on_input:
		($update_once as UpdateViewport).update_once(viewport)
	else:
		viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE

func _process(_dt: float) -> void:
	
	if !Engine.is_editor_hint(): # not in edtior
		if disable_collision:
			ui_collisionshape.disabled = true
		else:
			# if we are invisible we need to disable the collision shape to avoid interaction with the UIRayCast
			ui_collisionshape.disabled = not is_visible_in_tree()
		return

	# Not sure if it is a good idea to do this in the _process but at the moment it seems to 
	# be the easiest to show the actual canvas size inside the editor
	var last := ui_control
	find_child_control()
	if (ui_control != null):
		if (last != ui_control || ui_size != ui_control.get_size()):
			#print("Editor update size of ", name);
			update_size()
			_editor_update_preview()
		elif (editor_live_update):
			_editor_update_preview()
