extends Control

class_name CustomPopup

@onready var text: Label = %PopupText
@onready var text2: Label = %PopupText2
@onready var text3: Label = %PopupText3
@onready var timer: Timer = %PopupTimer
@onready var sfx: AudioStreamPlayer = %PopupSFX

signal on_popup_appeared
signal on_popup_disappeared

func set_popup(content: Array[String]) -> void:
	text.text = content[0]
	text2.text = content[1]
	text3.text = content[2]

func show_popup() -> void:
	show()
	sfx.play()
	on_popup_appeared.emit()
	
func hide_popup() -> void:
	hide()
	on_popup_disappeared.emit()
	
func start_popup_timer() -> void:
	timer.start()
	
func _on_popup_timer_timeout() -> void:
	hide_popup()
	timer.stop()
