extends Resource

class_name BodyParts

enum PartType {
	head,
	body,
	eyes,
	mouth,
	extra
}

enum Category {
	Animale,
	Supereroe,
	Mostri,
	Alieni,
	Cyborg,
	Cappelli,
	Corna,
	Capelli,
	Oggetto,
	Occhiali,
	OcchiDiGatto,
	Morto,
	BendaDaPirata,
	Maschera,
	Sorridente,
	Vampiro,
	Baffi,
	LabbraGrosse
}

@export var texture: Texture2D
@export var part_type: PartType
@export var category: Category
@export var id: int
