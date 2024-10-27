extends StaticBody2D


func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func _on_hitbox_area_entered(area):
	if area.name == "sword":
		$anim.play("Destroyed")
		await $anim.animation_finished
		queue_free()
