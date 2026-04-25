@tool
class_name Player
extends Node

signal color_changed(new_color: Color)
signal move_changed(amt: float)

@export var color := Color(1, 1, 1, 1):
	set(value):
		color = value
		color_changed.emit(value)

@export var speed := 5.0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var vel := 0.0
	if Input.is_key_pressed(KEY_LEFT):
		vel = -speed
	if Input.is_key_pressed(KEY_RIGHT):
		vel = speed
	move_changed.emit(vel)
