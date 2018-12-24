extends KinematicBody2D

const GRAVITY = 1000
const GROUND_ACCEL = 10
const AIR_ACCEL = 5
const MAX_SPEED = 140
const JUMP_SPEED = 420

enum {
	IDLE, 
	RUN, 
	JUMP
}

var velocity = Vector2()
var state
var anim
var new_anim

func _ready():
	change_state(IDLE)

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			new_anim = 'idle'
		RUN:
			new_anim = 'run'
		JUMP:
			new_anim = 'jump'

func get_input():
	var right = Input.is_action_pressed('player_right')
	var left = Input.is_action_pressed('player_left')
	var jump = Input.is_action_pressed('player_jump')
	var prevJump

	if (jump and !prevJump):
		change_state(JUMP)
		if (is_on_floor()):
			velocity.y = -JUMP_SPEED
			get_node("AudioStreamPlayer2D").play()
			
	prevJump = jump
			
	var accel
			
	if (state == JUMP):
		accel = AIR_ACCEL
	else:
		accel = GROUND_ACCEL
	
	if (right):
		if (velocity.x < MAX_SPEED):
			velocity.x += accel
		else:
			velocity.x = MAX_SPEED
			
		get_node("Sprite").flip_h = false
		
		if (is_on_floor()):
			change_state(RUN)
			
	if (left):
		if (velocity.x > -MAX_SPEED):
			velocity.x -= accel
		else:
			velocity.x = -MAX_SPEED
			
		get_node("Sprite").flip_h = true
		
		if (is_on_floor()):
			change_state(RUN)
			
	if (!right and !left):
		if (state == RUN):
			change_state(IDLE)
		
		if (velocity.x > 0):
			velocity.x -= accel
		elif (velocity.x < 0):
			velocity.x += accel

func _process(delta):
	get_input()
	if (new_anim != anim):
		anim = new_anim
		get_node("Sprite/AnimationPlayer").stop();
		
	if (!get_node("Sprite/AnimationPlayer").is_playing()):	
		get_node("Sprite/AnimationPlayer").play(anim)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if (state == JUMP and is_on_floor()):
		change_state(IDLE)
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
