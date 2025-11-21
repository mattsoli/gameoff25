extends Node3D

class_name TargetConfig

@export var category_db: Array[Category]

@export var all_body_parts: Array[BodyParts]
@export var max_valid_parts: int
@export var max_invalid_parts: int

var valid_categories: Array[Category]
var valid_category_types: Array[int]
var invalid_categories: Array[Category]

var valid_config: Array[BodyParts]
var valid_body_types: Array[int]
var invalid_config: Array[BodyParts]

func _ready() -> void:
	#valid_config = create_config(max_valid_parts)
	#invalid_config = create_anticonfig(valid_config, max_invalid_parts)
	
	valid_categories = create_category_config(max_valid_parts)
	invalid_categories = create_category_anticonfig(valid_categories, max_invalid_parts)
	
	var valid_names: Array[String] = []
	for cat: Category in valid_categories:
		valid_names.append(Category.CategoryType.keys()[cat.category_type])
	
	var invalid_names: Array[String] = []
	for cat: Category in invalid_categories:
		invalid_names.append(Category.CategoryType.keys()[cat.category_type])
		
	print("Valid categories: ", valid_names)
	print("Invalid categories: ", invalid_names)


func create_category_config(max_parts: int) -> Array:
	var result: Array
	if category_db.size() < (max_parts):
		push_error("Non ci sono abbastanza Category per creare un config!")
		return []
	
	var categories_copy: Array[Category] = category_db.duplicate()
	categories_copy.shuffle()
	result = categories_copy.slice(0, max_parts)
	
	for category: Category in result:
		valid_categories.append(category)
	
	return result

func create_category_anticonfig(target_config: Array, max_parts: int) -> Array:
	var result: Array
	var category_available: Array[Category] = []
	
	for category: Category in category_db:
		if category not in target_config and category.category_type not in valid_category_types:
			category_available.append(category)
	
	if category_available.size() < max_parts:
		push_error("Non ci sono abbastanza Category per creare l'anticonfig!")
		return []
	
	category_available.shuffle()
	result = category_available.slice(0, max_parts)
			
	return result

func create_config(max_parts: int) -> Array:
	var config: Array 
	if all_body_parts.size() < max_parts:
		push_error("Non ci sono abbastanza BodyParts per creare un config!")
		return []

	var parts_copy: Array[BodyParts] = all_body_parts.duplicate()
	parts_copy.shuffle()
	config = parts_copy.slice(0, max_parts)
	
	for conf: BodyParts in config:
		valid_body_types.append(conf.category)
		
	return config

func create_anticonfig(_target_config: Array, max_parts: int) -> Array:
	var available: Array[BodyParts] = []
	var config: Array
	
	for body_part: BodyParts in all_body_parts:
		if body_part not in _target_config and body_part.part_type not in valid_body_types:
			available.append(body_part)
		
	if available.size() < max_parts:
		push_error("Non ci sono abbastanza BodyParts per creare l'anticonfig!")
		return []

	available.shuffle()
	config = available.slice(0, max_parts)

	return config
