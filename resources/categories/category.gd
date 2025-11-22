extends Resource

class_name Category

enum CategoryType {
	Alieno,
	Animale,
	Cowboy,
	Cyborg,
	Gentleman,
	Guerriero,
	Morto,
	Mostro,
	Scienziato,
	Stregone,
	Supereroe,
	Neutro,
}

@export var icon: Texture2D
@export var category_type: CategoryType
