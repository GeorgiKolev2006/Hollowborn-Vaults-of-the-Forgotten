extends Node
class_name Player_data



@export var Playerspeed = 70
@export var coin = 0
@export var health = 4
@export var SavePos: Vector2 = Vector2.ZERO

func UpdatePos(value : Vector2):
	SavePos += value
