extends CanvasLayer

const HEART_ROW_SIZE = 8
const HEART_OFFSET = 16

func _ready():
	update_hearts_display()

func _process(delta: float) -> void:
	$coin_number.text = str(int(PlayerData.coin))
	$score.text = "🏆 " + str(int(PlayerData.score))

	for heart in $heart.get_children():
		var index = heart.get_index()
		var x = (index % HEART_ROW_SIZE) * HEART_OFFSET
		var y = (index / HEART_ROW_SIZE) * HEART_OFFSET
		heart.position = Vector2(x, y)
		
		var last_heart = floor(PlayerData.health)
		if index > last_heart:
			heart.frame = 0
		elif index == last_heart:
			heart.frame = (PlayerData.health - last_heart) * 4
		else:
			heart.frame = 4

func update_hearts_display():
	# Clear old hearts
	for heart in $heart.get_children():
		heart.queue_free()

	await get_tree().process_frame  # Important to clear first!

	# Create based on health
	for i in range(PlayerData.health):
		var new_heart = Sprite2D.new()
		new_heart.texture = $heart.texture
		new_heart.hframes = $heart.hframes
		$heart.add_child(new_heart)
