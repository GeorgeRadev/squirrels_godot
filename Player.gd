extends KinematicBody

export(String, "p1", "p2") var player
export (String) var playerName
export (int) var playerCollected

var gravity : Vector3 = Vector3.DOWN * 14
var speed : float = 4
var jump_speed : float = 8
var velocity : Vector3 = Vector3()
var can_eat:bool = false
var has_acorn:bool = false
var worldOrientation:float
var camera:Camera = null
var button:Button = null

onready var acorn  =  $Acorn
onready var playerAnimation: AnimationPlayer  =  $Spatial/Squirrel/AnimationPlayer

# player states
enum STATE {
	IDLE, # on ground
	RUN, # on ground
	EAT, # on ground
	JUMP, # from ground to air
	FALL, # in air, until on the floor
}
var playerStateOld = STATE.IDLE
var playerState = STATE.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	worldOrientation = 1 if player == "p2" else -1
	var __ = playerAnimation.connect("animation_finished", self, "animation_finished")
	playerAnimation.get_animation("idle").set_loop(true)
	playerAnimation.get_animation("eat").set_loop(false)
	playerAnimation.get_animation("fal").set_loop(true)
	playerAnimation.get_animation("run").set_loop(true)
	playerAnimation.get_animation("jump").set_loop(false)
	playerAnimation.play("idle")
	playerState = STATE.IDLE
	if worldOrientation == -1:
		#ff9514
		apply_texture_color($Spatial/Squirrel/Armature/Skeleton/body, 0xff9514ff)
		apply_texture_color($Spatial/Squirrel/Armature/Skeleton/tail, 0xff9514ff)
		apply_texture_color($Spatial/Squirrel/Armature/Skeleton/nose, 0x010101ff)
	else:
		apply_texture_color($Spatial/Squirrel/Armature/Skeleton/body, 0xff7d26ff)
		apply_texture_color($Spatial/Squirrel/Armature/Skeleton/tail, 0xff7d26ff)
		apply_texture_color($Spatial/Squirrel/Armature/Skeleton/nose, 0xff3030ff)
		


func apply_texture_color(mesh_instance_node, color):
	var material = SpatialMaterial.new()
	material.albedo_color = Color(color)
	mesh_instance_node.set_material_override(material)


func setCamera(c:Camera):
	camera = c


func setButton(b: Button):
	button = b


func can_eat(eat:bool):
	can_eat = eat


func can_collect():
	if has_acorn:
		playerCollected += 1
		has_acorn = false
		button.text = getText()


func getText():
	var text = playerName + ": " + str(playerCollected)
	if has_acorn: text = text + " +"
	return text 

func _physics_process(delta):
	acorn.visible = has_acorn
	# falling
	velocity += gravity * delta
	
	# keep  gravity
	var velocity_y = velocity.y
	velocity = Vector3.ZERO
	velocity.z = 0
	if Input.is_action_pressed(player + "_left"):
		velocity.x = worldOrientation
	if Input.is_action_pressed(player + "_right"):
		velocity.x = -worldOrientation
	velocity = velocity.normalized() * speed
	# restore gravity
	velocity.y = velocity_y
	
	# move player up without collision
	var is_on_floor: bool = is_on_floor()
	if velocity_y >= 0:
		transform.origin += delta * velocity
		is_on_floor = false
	else: 
		velocity = move_and_slide(velocity, Vector3.UP)
		is_on_floor = is_on_floor()
	
	if transform.origin.x >  3: transform.origin.x = 3
	if transform.origin.x < -3: transform.origin.x = -3
	if camera != null : camera.transform.origin.y = transform.origin.y + 2
	

	#rotate player
	if velocity.x > 0.1 : rotation.y = 0
	elif velocity.x < -0.1 : rotation.y = PI
	#else: rotation.y = PI/2

	if is_on_floor: #ground
		var action_pressed: bool = Input.is_action_just_pressed(player + "_action")	
		var jump_pressed: bool = Input.is_action_just_pressed(player + "_jump")
		if playerState != STATE.EAT: 
			var moving: bool = abs(velocity.x) > 0.2 or abs(velocity.z) > 0.2
			if moving:
				playerState = STATE.RUN
			else:
				playerState = STATE.IDLE
		if action_pressed:
			if can_eat:
				playerState = STATE.EAT
				has_acorn = true
				button.text = getText()
		if jump_pressed:
			velocity.y = jump_speed
			playerState = STATE.JUMP
			#audio_jump.play(0)
	updateAnimation()


func updateAnimation():
	# set animation
	if(playerStateOld != playerState):
		playerStateOld = playerState
		match playerState:
			STATE.IDLE: 
				playerAnimation.play("idle")
				#if audio_run.is_playing():
				#	audio_run.stop()
			STATE.RUN:
				playerAnimation.play("run", -1, 1)
				#if ! audio_run.is_playing():
				#	var stream:AudioStreamOGGVorbis = audio_run.stream
				#	stream.loop = true
				#	audio_run.play()
			STATE.EAT:
				playerAnimation.play("eat")
			STATE.JUMP:
				playerAnimation.play("jump")
			STATE.FALL:
				playerAnimation.play("fal")


func animation_finished(anim_name : String):
	if "jump" == anim_name:
		playerState = STATE.FALL
	else:
		playerState = STATE.IDLE
	updateAnimation()

