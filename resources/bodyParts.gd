extends Resource

class_name BodyParts

enum PartsType {
	#ears,
	head,
	body,
	#arms,
	#legs,
	eyes,
	#nose,
	#mouth
}

@export var texture: Texture2D
@export var partType: PartsType
@export var id: int

func _init():
	pass
