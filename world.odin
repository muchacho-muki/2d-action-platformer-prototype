package main

import rl "vendor:raylib"

//used to toggle any bool
toggle :: proc(BOOL: ^bool){
	BOOL^ = !(BOOL)^
}

//takes input related to world like show boxes or spawn enemies (could have a better name but this is what i am going with)
world_input :: proc(Enemies_list : ^[dynamic]Entity){
	if rl.IsKeyPressed(.B){toggle(&show_boxes)}

	if rl.IsKeyPressed(.X){Create_enemies(Enemies_list, 1.0, 1.0)}
}

//draws instructions on what button does what :p
draw_text :: proc(){
	rl.DrawText("press B to toggle box visibiltiy", 10, 40, 20, rl.WHITE)
	rl.DrawText("press X to spawn enemies", 10, 60, 20, rl.RED)
}