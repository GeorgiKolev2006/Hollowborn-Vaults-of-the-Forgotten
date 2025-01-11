extends CharacterBody2D

@onready var anim_tree = $anim_tree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var coin_scene = preload("res://Scenes/Interactables/coin.tscn")

var save_directory = "user://save/"
var save_file_name = "PlayerSave.save"
var save_file_path = save_directory + save_file_name

enum player_states {MOVE, SWORD, JUMP, DEAD}
var current_states = player_states.MOVE


var input_movement = Vector2.ZERO
var playerData = Player_data.new()

func _ready():
	$sword.add_to_group("Sword")
	$sword/CollisionShape2D.disabled = true
	load_data()
	

func _process(delta):
	if Input.is_action_just_pressed("save"):  
		save_data()
	if Input.is_action_just_pressed("load"):
		load_data()
	if Input.is_action_just_pressed("deletesave"):
		print("F7 pressed!")

func _physics_process(delta):
	match current_states:
		player_states.MOVE:	
			move()
		player_states.SWORD:
			sword()
		player_states.JUMP:
			jump()
		player_states.DEAD:
			dead()

func move():
	input_movement = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_movement != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_movement)
		anim_tree.set("parameters/Walk/blend_position", input_movement)
		anim_tree.set("parameters/Sword/blend_position", input_movement)
		anim_tree.set("parameters/Jump/blend_position", input_movement)
		anim_state.travel("Walk")
		velocity = input_movement * playerData.Playerspeed
	
	if input_movement == Vector2.ZERO:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO
		
	if Input.is_action_just_pressed("sword"):
		current_states = player_states.SWORD
	
	if Input.is_action_just_pressed("jump"):
		current_states = player_states.JUMP
	
	if player_data.health <= 0:
		current_states = player_states.DEAD
	
	move_and_slide()

func sword():
	anim_state.travel("Sword")

func on_states_reset():
	current_states = player_states.MOVE

func jump():
	anim_state.travel("Jump")
	velocity = input_movement * playerData.Playerspeed
	move_and_slide()

func dead():
	anim_state.travel("Dead")
	await get_tree().create_timer(1).timeout
	player_data.health = 4
	get_tree().reload_current_scene()

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)
	
func clear_collision():
	$CollisionShape2D.disabled = true

func create_collision():
	$CollisionShape2D.disabled = false

func _on_hitbox_area_entered(area):
	take_damage()
	flash()

func take_damage():
	if player_data.health > 0:
		player_data.health -= 1
		print("Player Health: ", player_data.health)
		flash()
		if player_data.health <= 0:
			current_states = player_states.DEAD
	else:
		print("Player is already dead!")


func save_data():
	var dir_access = DirAccess.open(save_directory)
	if dir_access == null:
		print("Directory does not exist, creating it...")
		var dir = DirAccess.open("user://")
		dir.make_dir("save")
	else:
		print("Directory exists!")
	
	# Save data to the file
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if save_file == null:
		print("Failed to open file for saving.")
		return
	else:
		print("File opened for saving.")
	
	var data_to_save = {
		"position": position,
		"health": player_data.health,
		"coin": player_data.coin
	}
	print("Saving data: ", data_to_save)
	save_file.store_var(data_to_save)
	save_file.close()
	print("File saved and closed.")


func delete_save():
	if Input.is_action_just_pressed("deletesave"):
		print("F7 pressed!")

		var file_path = save_file_path + save_file_name
		print("File Path: ", file_path)  # Debug log for the file path

		var dir = DirAccess.open("user://")
		if dir:
			print("Directory opened successfully!")  # Debug log for successful directory access
			
			if dir.file_exists(file_path):
				print("File exists: ", file_path)  # Debug log for file existence check
				var err = dir.remove(file_path)
				if err == OK:
					print("Save file deleted successfully.")
				else:
					print("Error deleting file:", err)
			else:
				print("No save file found to delete.")
		else:
			print("Failed to open directory.")



func load_data():
	var loaded_data = FileAccess.open(save_file_path, FileAccess.READ)
	if loaded_data == null:
		print("Failed to open file for loading.")
		return
	else:
		print("File opened for loading.")
	
	var data = loaded_data.get_var()
	print("Loaded data: ", data)
	
	if data:
		position = data["position"]
		player_data.health = data["health"]
		player_data.coin = data["coin"]
		print("Game data loaded successfully.")
	else:
		print("No data to load.")
	
	loaded_data.close()
	print("File loaded and closed.")


func apply_loaded_data():
	position = playerData.SavePos
	playerData.health = playerData.health
	playerData.coin = playerData.coin
