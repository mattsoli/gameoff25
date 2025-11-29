extends Resource

class_name Category

enum CategoryType {
	Alieno,
	Animale,
	Pirata,
	Cyborg,
	Gentleman,
	Zombie,
	Mostro,
	Scienziato,
	Mago
}

@export var icon: Texture2D
@export var category_type: CategoryType
