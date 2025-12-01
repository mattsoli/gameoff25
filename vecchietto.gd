extends Control

class_name Vecchietto

@onready var audio_player: AudioStreamPlayer = %AudioPlayer
@export var hail_sfx: AudioStream
@export var wrong_sfx: AudioStream
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func hail() -> void:
	audio_player.stream = hail_sfx
	audio_player.play()
	
	anim_player.play("hail")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	anim_player.play("idle")
