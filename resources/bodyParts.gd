extends Resource

class_name BodyParts

enum PartsType {
	head,
	body,
	eyes,
	#ears,
	#arms,
	#legs,
	#nose,
	#mouth
}

@export var texture: Texture2D
@export var partType: PartsType
@export var id: int
