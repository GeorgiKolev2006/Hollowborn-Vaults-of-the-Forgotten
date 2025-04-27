extends State

@onready var left_hitbox: Area2D = owner.get_node("LeftHitbox")
@onready var right_hitbox: Area2D = owner.get_node("RightHitbox")

var melee_damage := 5

func enter():
	super.enter()
	animation_player.play("melee_attack")

	if left_hitbox and not left_hitbox.is_connected("body_entered", Callable(self, "_on_body_entered")):
		left_hitbox.connect("body_entered", Callable(self, "_on_body_entered"))
	if right_hitbox and not right_hitbox.is_connected("body_entered", Callable(self, "_on_body_entered")):
		right_hitbox.connect("body_entered", Callable(self, "_on_body_entered"))

	print("✅ Entered MeleeAttack state")
	print("✅ Left Hitbox:", left_hitbox)
	print("✅ Right Hitbox:", right_hitbox)

	await animation_player.animation_finished
	transition()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		print("👊 Golem hit the player!")
		body.take_damage(Vector2(melee_damage, 0))  # << fix here!

func transition():
	if owner.direction.length() > 30:
		get_parent().change_state("Follow")
