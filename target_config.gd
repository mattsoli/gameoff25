extends Node3D

class_name TargetConfig

@export var all_body_parts: Array[BodyParts]
@export var max_valid_parts: int
@export var max_invalid_parts: int

var valid_config: Array[BodyParts]
var invalid_config: Array[BodyParts]

func _ready() -> void:
	valid_config = create_config(max_valid_parts)
	invalid_config = create_anticonfig(valid_config, max_invalid_parts)
	
func create_config(max_parts: int) -> Array:
	var config: Array 
	if all_body_parts.size() < max_parts:
		push_error("Non ci sono abbastanza BodyParts per creare un config!")
		return []

	var parts_copy: Array[BodyParts] = all_body_parts.duplicate()
	parts_copy.shuffle()
	config = parts_copy.slice(0, max_parts)
	
	return config

func create_anticonfig(_target_config: Array, max_parts: int) -> Array:
	var available: Array[BodyParts] = []
	var config: Array
	
	for part: BodyParts in all_body_parts:
		if part not in _target_config:
			available.append(part)

	if available.size() < max_parts:
		push_error("Non ci sono abbastanza BodyParts per creare l'anticonfig!")
		return []

	available.shuffle()
	config = available.slice(0, max_parts)

	return config
