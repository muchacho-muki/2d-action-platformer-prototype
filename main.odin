package main

import rl "vendor:raylib"
import fmt "core:fmt"
import b2 "vendor:box2d"
import rand "core:math/rand"

//makes box2d world global
WorldId : b2.WorldId

//makes frame time global
dt : f32

//box2d world related stuff
TimeStep :: 1.0 / 60.0
SubStepCount :: 4

//collision codes so i can decide what can collide with what
PLAYER_Collision        :: u64(1 << 0)
ENEMY_Collision         :: u64(1 << 1)
GROUND_Collision        :: u64(1 << 2)

//a bool to control visibility of boxes for player and enemies
show_boxes : bool = false

main :: proc(){

	//making window
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(1600,800, "2D action platformer")
	defer rl.CloseWindow()

	//loading background image
	background:= rl.LoadTexture("assets/walls/bg.png")

	//setting fps and box2d untils per meter
	rl.SetTargetFPS(60)
	b2.SetLengthUnitsPerMeter(128)

	//making box2d world
	worldDef := b2.DefaultWorldDef();
	worldDef.gravity = {0, 9.8 * 128}
	WorldId = b2.CreateWorld(worldDef);

	//static blocks and enemies list
	BLOCKS : [dynamic]Block
	Enemies_list : [dynamic]Entity

	//walls and floor
	{
	make_blocks(&BLOCKS, {800, 780}, {1600, 20})
	make_blocks(&BLOCKS, {0,400}, {20, 800})
	make_blocks(&BLOCKS, {1600 - 20, 400}, {20, 800})
	}

	//main 2d camera
	camera := make_cam()

	//making player using the entity struct
	player := Entity{
		texture = Player_tex(),
		State = .idle,

		category = PLAYER_Collision,
		mask = GROUND_Collision,

		pos = {800, 400},
		size = {30, 50},
		speed = 400.0,
		jump_boost = 500.0,
		Health = 1000.0,
		damage = 10.0,

		facing = .right,
	}

	//giving player a physics body
	Create_Entity_Physics_body(&player)

	//player animations details
	player.animation = Animations{
		frames_speed = 5,
		frame_size = {60, 50},
		scale = 1.5,
	}

	//creating enemies
	Create_enemies(&Enemies_list, 1, 1.0)

	//gameloop
	for !rl.WindowShouldClose(){
		b2.World_Step(WorldId, TimeStep, SubStepCount);
		dt = rl.GetFrameTime()

		//updates cam pos and takes input
		update_cam(&camera, player)
		world_input(&Enemies_list)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.BeginMode2D(camera)

		//draws background
		rl.DrawTexturePro(background, {0, 0, f32(background.width), f32(background.height)}, {0, 0, 1600,800}, {0, 0}, 0, rl.WHITE)

		//draws and updates player and enemies
		Update_player(&player, &Enemies_list)
		Update_enemies(&Enemies_list, &player)

		//draws walls and ground
		draw_blocks(BLOCKS)

		//draws enemy and player hit and hurt boxes.
		Draw_boxes(player, Enemies_list, show_boxes)

		rl.EndMode2D()

		//draws fps and instructions
		rl.DrawFPS(10,10)
		draw_text()

		rl.EndDrawing()
	}
}