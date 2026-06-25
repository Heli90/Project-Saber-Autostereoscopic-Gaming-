extends Node3D

@onready var jeu: Node3D = $Game
@onready var menu: Control = $Menu
@onready var j1: Node3D = $SplitScreens/Camera1/POV1/J1
@onready var j2: Node3D = $SplitScreens/Camera2/POV2/J2
@onready var pause_menu: ColorRect = $Game/HUD/PauseMenu
@onready var start_label: Label = $Game/StartLabel
@onready var disappear_bloc_notif: Label = $Game/DisappearBlocNotif

const IDLE_TIMEOUT = 5.0  # 5 secondes avant de cacher le menu
var idle_timer: float = 0.0
var is_hidden: bool = false

func _ready() -> void:
	GlobalMusic.play()

func _process(delta: float) -> void:
	idle_timer += delta
	if idle_timer >= IDLE_TIMEOUT and not is_hidden:
		is_hidden = true
		var t = create_tween()
		t.tween_property(menu, "modulate:a", 0.0, 0.5)
		await t.finished

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventKey or event is InputEventMouseButton:
		idle_timer = 0.0
		if is_hidden:
			is_hidden = false
			var t = create_tween()
			t.tween_property(menu, "modulate:a", 1.0, 0.5)
			await t.finished
	if event.is_action_pressed("ResetLeaderboard"): jeu.reset_leaderboard()
