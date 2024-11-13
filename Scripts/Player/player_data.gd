extends Node
class_name Player_data

var Playerspeed = 70
var coin = 0
var health = 4
@export var SavePos : Vector2

func UpdatePos(value : Vector2):
	SavePos += value
