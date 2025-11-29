extends Control

class_name CustomPopup

@onready var mainText: Label = %PopupMainText
@onready var timer: Timer = %PopupTimer
@onready var sfx: AudioStreamPlayer = %PopupSFX

signal on_popup_appeared
signal on_popup_disappeared

func set_popup(_mainText: String) -> void:
	mainText.text = _mainText

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
