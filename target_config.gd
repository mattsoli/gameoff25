extends Node3D

class_name TargetConfig

@export var category_db: Array[Category]

var valid_categories: Array[Category]
var valid_category_types: Array[Category.CategoryType]
var max_valid_category: int

var invalid_categories: Array[Category]
var invalid_category_types: Array[Category.CategoryType]
var max_invalid_category: int

func set_target_config(max_valid_category_count: int, max_invalid_category_count: int) -> void:
	max_valid_category = max_valid_category_count
	max_invalid_category = max_invalid_category_count
	
	# Crea una copia dell'array originale
	var available_categories: Array[Category] = category_db.duplicate()
	available_categories.shuffle()
	
	# Seleziona le categorie valide
	for i: int in range(min(max_valid_category, available_categories.size())):
		valid_categories.append(available_categories[i])
	
	# Rimuovi le categorie valide da quelle disponibili
	for cat: Category in valid_categories:
		available_categories.erase(cat)
	
	# Seleziona le categorie invalide dalle rimanenti
	for i: int in range(min(max_invalid_category, available_categories.size())):
		invalid_categories.append(available_categories[i])
		
	for category: Category in valid_categories:
		valid_category_types.append(category.category_type)
		
	for category: Category in invalid_categories:
		invalid_category_types.append(category.category_type)
		
func get_random_category(category_array: Array[Category]) -> Category:
	var categories_copy: Array[Category] = category_array.duplicate()
	categories_copy.shuffle()
	return categories_copy.pick_random()
