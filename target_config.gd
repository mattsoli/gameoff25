extends Node3D

@export var all_body_parts: Array[BodyParts]
@export var max_valid_parts: int
@export var max_invalid_parts: int

var target_config: Array[BodyParts]
func _ready() -> void:
	create_config(max_valid_parts)

func create_config(max_parts: int) -> void:
	if all_body_parts.size() < max_parts:
		push_error("Non ci sono abbastanza BodyParts unici!")
		return

	var parts_copy: Array[BodyParts] = all_body_parts.duplicate()
	parts_copy.shuffle()
	target_config = parts_copy.slice(0, max_parts)
	
	print(target_config)
