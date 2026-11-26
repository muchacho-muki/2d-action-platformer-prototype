package main

import rl "vendor:raylib"
import b2 "vendor:box2d"


//holds data related to static body, mostly box2d body id and the size (only supports rectangle)
Block :: struct{
	id : b2.BodyId,
	size: [2]f32
}

//makes box2d bodyid for the blocks and appends them to a list, these bodies do not move.
make_blocks :: proc(BLOCKS : ^[dynamic]Block, pos: [2]f32, size: [2]f32){
	blockBodyDef := b2.DefaultBodyDef()
	blockBodyDef.position = pos
	blockId := b2.CreateBody(WorldId, blockBodyDef)
	blockBox := b2.MakeBox(size.x/2, size.y/2)

	blockShapeDef := b2.DefaultShapeDef()
	
	blockShapeDef.filter.categoryBits = GROUND_Collision
	blockShapeDef.filter.maskBits = PLAYER_Collision | ENEMY_Collision

	_ = b2.CreatePolygonShape(blockId, blockShapeDef, blockBox)

	block := Block{
		id = blockId,
		size = size,
	}

	append(BLOCKS , block)
}

//draws the static bodies
draw_blocks :: proc(BLOCKS : [dynamic]Block){
	for block in BLOCKS{
		pos := b2.Body_GetPosition(block.id)
		shape := rl.Rectangle{pos.x - block.size.x/2, pos.y - block.size.y/2, block.size.x, block.size.y}
		// rl.DrawRectangleLinesEx(shape, 1.0, rl.RED)
		rl.DrawRectangleRec(shape, rl.BLACK)
	}
}