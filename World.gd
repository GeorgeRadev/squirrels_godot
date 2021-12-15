extends Spatial

var levelContainer:Spatial = null
var currentLevel:int = 0
var collect_for_next_level = 10

onready var ViewportContainerP1 = $ViewportContainerP1
onready var ViewportContainerP2 = $ViewportContainerP2
onready var ViewportP1:Viewport = $ViewportContainerP1/ViewportP1
onready var ViewportP2:Viewport = $ViewportContainerP2/ViewportP2
onready var cameraP1:Camera = $ViewportContainerP1/ViewportP1/CameraP1
onready var cameraP2:Camera = $ViewportContainerP2/ViewportP2/CameraP2

onready var P1 = $Players/Player1
onready var P2 = $Players/Player2

var Top_tree = preload("res://Top.tscn")
var Trunk = preload("res://Trunk.tscn")
var Leaves = preload("res://Leaves.tscn")
var Branch = preload("res://Branch.tscn")


func _ready():
	set_process_input(true)
	randomize()
	var _err = get_tree().get_root().connect("size_changed", self, "resize")
	# OS.window_fullscreen = true
	resize()
	$Players/Player1.setCamera(cameraP1)
	$Players/Player1.setButton($ViewportContainerP1/TextP1)
	$Players/Player2.setCamera(cameraP2)
	$Players/Player2.setButton($ViewportContainerP2/TextP2)
	
	nextLevel()


func _process(delta):
	if P1.playerCollected >= collect_for_next_level and P2.playerCollected >= collect_for_next_level:
		nextLevel()


func nextLevel():
	currentLevel += 1
	if currentLevel > 10:
		currentLevel = 1
	generateLevel(currentLevel)


func _input(event):
	if event.is_action_pressed("ui_select"):
		nextLevel()


func resize():
	var viewport_size = get_viewport().size
	var width = viewport_size.x
	var height = viewport_size.y
	var mid = int(width/2)
	
	ViewportContainerP1.margin_left = 0
	ViewportContainerP1.margin_top = 0
	ViewportContainerP1.margin_bottom = height
	ViewportContainerP1.margin_right = int(width/2) - 1
	
	ViewportContainerP2.margin_left = mid + 1
	ViewportContainerP2.margin_top = 0
	ViewportContainerP2.margin_bottom = height
	ViewportContainerP2.margin_right = width
	
	ViewportP1.set_size_override(true, Vector2(mid, height))
	ViewportP2.set_size_override(true, Vector2(mid, height))



func generateRandomLevel(level:int):
	#add the top of the tree
	var trunk = Trunk.instance()
	trunk.translate(Vector3(0, 5 * level, 0))
	levelContainer.add_child(trunk)
	# add leaves
	for leaveId in range(5):
		var s = Vector3(0.7 + 0.3*randf(), 1, 1)
		var p = Vector3(-3 + randf() * 6, 5*level + leaveId, 1)
		var l = Vector2(p.x, p.z).length()
		var a = atan2(-p.z, p.x)
		# add on the one side
		var leave = Leaves.instance()
		leave.scale_object_local(s)
		leave.translate(p)
		levelContainer.add_child(leave)
		# add branch
		var branch = Branch.instance()
		branch.translate(Vector3(0,p.y,0))
		branch.scale_object_local(Vector3(l,l,1))
		branch.rotate_object_local(Vector3.UP, a)
		levelContainer.add_child(branch)
		# add the same in the other side
		p.z = -p.z
		p.x = -p.x
		leave = Leaves.instance()
		leave.scale_object_local(s)
		leave.translate(p)
		levelContainer.add_child(leave)
		# add branch
		branch = Branch.instance()
		branch.translate(Vector3(0,p.y,0))
		branch.scale_object_local(Vector3(l,l,1))
		branch.rotate_object_local(Vector3.UP, PI+a)
		levelContainer.add_child(branch)

func generateLevel(level:int):
	P1.playerCollected = 0
	$ViewportContainerP1/TextP1.text = P1.getText()
	P1.transform.origin = Vector3(2,-0.5,1)
	P2.playerCollected = 0
	$ViewportContainerP2/TextP2.text = P2.getText()	
	P2.transform.origin = Vector3(-2,-0.5,-1)
	$TextLevel.text = "LEVEL: "+str(level)
	
	var oldLevelContainer = levelContainer
	# create level object container
	levelContainer = Spatial.new()
	add_child(levelContainer)

	for l in range(level):
		generateRandomLevel(l)
	
	#add the top of the tree
	var top = Top_tree.instance()
	top.translate(Vector3(0, 5 * level, 0))
	levelContainer.add_child(top)
	
	# delete old level elements
	if oldLevelContainer != null:
		remove_child(oldLevelContainer)
		oldLevelContainer.queue_free()
