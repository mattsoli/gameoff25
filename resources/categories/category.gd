extends Resource

class_name Category

enum CategoryType {
	Alieno,
	Animale,
	Baffi,
	BendaDaPirata,
	Capelli,
	Cappello,
	Corna,
	Cyborg,
	LabbraGrosse,
	Maschera,
	Morto,
	Mostro,
	Neutro,
	Occhiali,
	OcchiDiGatto,
	Oggetto,
	Sorridente,
	Supereroe,
	Vampiro,
}

@export var icon: Texture2D
@export var category_type: CategoryType
