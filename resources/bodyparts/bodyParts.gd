extends Resource

class_name BodyParts

enum PartType {
	head,
	body,
	eyes,
	#ears,
	#arms,
	legs,
	#nose,
	#mouth
}

@export var texture: Texture2D
@export var part_type: PartType
@export var id: int
