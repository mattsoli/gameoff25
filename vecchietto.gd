extends Control

class_name Vecchietto

@onready var audio_stream: AudioStreamPlayer = %AudioPlayer
@export var hail_sfx: AudioStream
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func hail() -> void:
	audio_stream.stream = hail_sfx
	audio_stream.play()
	
	anim_player.play("hail")
	
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	pass # Replace with function body.
	anim_player.play("idle")
