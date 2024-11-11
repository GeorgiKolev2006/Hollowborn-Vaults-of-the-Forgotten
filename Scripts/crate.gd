extends StaticBody2D
var coin_scene = preload("res://Scenes/Interactables/Coin.tscn")

func _ready():
	pass 


func _process(delta):
	pass


func _on_hitbox_area_entered(area):
	if area.name == "sword":
		$anim.play("Destroyed")
		await $anim.animation_finished
		drop_coin()
		queue_free()

func drop_coin():
	if randf() < 0.15:
		var coin_instance = coin_scene.instantiate()
		coin_instance.position = position
		get_parent().add_child(coin_instance)
