extends CharacterBody2D
class_name Character

@onready var earsSlot: Sprite2D = $Ears/Sprite2D
@onready var headSlot: Sprite2D = $Head/Sprite2D
@onready var bodySlot: Sprite2D = $Body/Sprite2D
@onready var armsSlot: Sprite2D = $Arms/Sprite2D
@onready var legsSlot: Sprite2D = $Legs/Sprite2D
@onready var eyesSlot: Sprite2D = $Eyes/Sprite2D
@onready var noseSlot: Sprite2D = $Nose/Sprite2D
@onready var mouthSlot: Sprite2D = $Mouth/Sprite2D

var speed: float = 50.0
var direction: Vector2 = Vector2.RIGHT
var is_target: bool = false
var caracteristics: Dictionary = {}
const MAX_PART_ID: int = 2
var is_hailed: bool = false

signal character_clicked(character)

func _ready() -> void:
	caracteristics = generate_random_body_config()

	var clickArea = %ClickCollider
	clickArea.input_event.connect(_on_input_event)
	
func generate_random_body_config() -> Dictionary:
	var body_config: Dictionary = {}
	
	for part_type in BodyParts.PartsType.values():
		var part_name = BodyParts.PartsType.keys()[part_type]
		
		body_config[part_name] = randi_range(1, MAX_PART_ID)
		
		match part_name:
			"head":
				headSlot.texture = load("res://resources/%s_%d.tres" % [part_name, body_config[part_name]]).texture
			"body":
				bodySlot.texture = load("res://resources/%s_%d.tres" % [part_name, body_config[part_name]]).texture
			"eyes":
				eyesSlot.texture = load("res://resources/%s_%d.tres" % [part_name, body_config[part_name]]).texture
		
	return body_config

func _physics_process(_delta: float ) -> void:
	velocity = direction * speed
	move_and_slide()
	
	if position.x > get_viewport_rect().size.x + 100:
		queue_free()

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("character_clicked", self)
