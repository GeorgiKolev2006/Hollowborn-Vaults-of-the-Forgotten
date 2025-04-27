extends State

var can_transition: bool = false

func enter():
	super.enter()

	# Try to get Player via detection node
	if $"../../PlayerDetection".has_overlapping_bodies():
		for body in $"../../PlayerDetection".get_overlapping_bodies():
			if body.is_in_group("Player"):
				player = body
				break

	# Fallback if detection node fails
	if player == null:
		player = get_tree().get_root().find_child("Player", true, false)

	if player == null:
		print("⚠️ Dash aborted: Player not found.")
		return

	animation_player.play("glowing")
	await dash()
	can_transition = true

func dash():
	var tween = create_tween()
	tween.tween_property(owner, "position", player.position, 0.8)
	await tween.finished

func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")
