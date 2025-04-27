extends State

@onready var pivot: Node2D = $"../../pivot"
@onready var laser_area: Area2D = $"../../pivot/Sprite2D/Laser"
@onready var laser_shape: CollisionShape2D = laser_area.get_node("CollisionShape2D")

var can_transition: bool = false

func _ready():
	if not laser_area.is_connected("body_entered", Callable(self, "_on_laser_body_entered")):
		laser_area.connect("body_entered", Callable(self, "_on_laser_body_entered"))

	# 🔥 Disable the laser collision initially!
	if laser_shape:
		laser_shape.disabled = true

func enter():
	super.enter()
	set_target()

	can_transition = false
	animation_player.play("laser_cast")

	# Laser is charging = no damage yet
	if laser_shape:
		laser_shape.disabled = true

	await animation_player.animation_finished

	# Now laser fires = enable damage
	animation_player.play("laser")
	if laser_shape:
		laser_shape.disabled = false

	await animation_player.animation_finished

	# Laser done = disable again
	if laser_shape:
		laser_shape.disabled = true

	can_transition = true
	transition()

func set_target():
	var player = get_tree().get_root().find_child("Player", true, false)
	if player:
		var to_player_angle = (player.global_position - pivot.global_position).angle()
		pivot.rotation = to_player_angle

func _on_laser_body_entered(body: Node) -> void:
	if body and body.has_method("take_damage") and body.is_in_group("Player"):
		print("🔫 Laser hit the player!")
		body.take_damage(Vector2.ZERO)

func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")
