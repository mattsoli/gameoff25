extends Node3D

@onready var play_btn: Button = %PlayBtn
func _ready() -> void:
	play_btn.pressed.connect(_on_start_pressed)
	
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
