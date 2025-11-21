extends Resource

class_name BodyParts

enum PartType {
	head,
	body,
	eyes,
	mouth,
	extra
}

@export var texture: Texture2D
@export var part_type: PartType
@export var category: Category
@export var id: int
