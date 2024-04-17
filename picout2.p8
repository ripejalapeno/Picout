pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	igame()
	ipaddle()
	iball()
	ibrick()
end

function _update60()
	if game.state == 'play' then
		uplay()
	end
end

function _draw()
	cls()
	if game.state == 'play' then
		dplay()
	end
end
-->8
-- paddle --

-- init paddle --
function ipaddle()

	pdl = {
		col=7,
		spd=2,
		x=63,
		y=115,
		w=9,
		h=1
		}
		
end

-- update paddle --
function upaddle()

 -- player controls --

 if btn(➡️) then
 	pdl.x += pdl.spd
 	
 	-- right wall bounds --
 	if pdl.x + pdl.w + 1 >= 
 				127 - game.walls then
 				
 		pdl.x = 126 - pdl.w - game.walls
 	end
 end
 
 if btn(⬅️) then
 	pdl.x -= pdl.spd
 	
 	-- left wall bounds --
 	if pdl.x - pdl.w - 1 <=
 				game.walls then
 		pdl.x = 1 + pdl.w + game.walls
 	end	
 end
end

-- draw paddle --
function dpaddle()

	rectfill(
		pdl.x-pdl.w,
		pdl.y-pdl.h,
		pdl.x+pdl.w,
		pdl.y+pdl.h,
		pdl.col
		)
		
end
-->8
-- ball --

function iball()
	
	ball = {}
	
	ball.state='sticky'
	ball.col=7
	ball.x=63
	ball.y=80
	ball.dx=1
	ball.dy=-1
	ball.r=2
		
end

-- reset ball --
function rball()
	ball.x = pdl.x
	ball.y = pdl.y
	ball.state = 'sticky'
end

function uball()

	--hold ball
	if ball.state == 'sticky' then
		if btnp(❎) then
			ball.state = 'go'
		else
			if btn(➡️) then
				ball.dx=1
			elseif btn(⬅️) then
				ball.dx=-1
			end
			ball.x=pdl.x
			ball.y=pdl.y-ball.r-pdl.h-1
			return
		end
	end
	
	local new_x=ball.x+ball.dx
	local new_y=ball.y+ball.dy
	
	-- bounce walls --
	if new_x+ball.r >= 127-game.walls then
		new_x = 126-game.walls-ball.r
		ball.dx*=-1
		sfx(1)
	elseif	new_x-ball.r <= game.walls then
		new_x = game.walls+ball.r+1
		ball.dx*=-1
		sfx(1)
	end
	
	-- bounce ceiling --
	if new_y-ball.r-1<=game.ceil or new_y+ball.r>=127 then
		ball.dy*=-1
		sfx(1)
	end
	
	-- bounce paddle --
	if ball_hits(new_x,new_y,ball.r,pdl.x,pdl.y,pdl.w,pdl.h) then
		if ball_deflx(ball.x,ball.y,ball.dx,ball.dy,pdl.x,pdl.y,pdl.w,pdl.h) then
			ball.dx *= -1
		else
			ball.dy *= -1
		end
	end

	ball.x=new_x
	ball.y=new_y
	
end

function dball()

	circfill(ball.x,ball.y,
										ball.r,ball.col)
										
	if ball.state == 'sticky' then
		fillp(░)
		line(ball.x + (ball.dx * 3),
							ball.y + (ball.dy * 3),
							ball.x + (ball.dx * 15),
							ball.y + (ball.dy * 15))
		fillp()
	end
end

function ball_hits(bx,by,br,box_x,box_y,box_w,box_h)
	if bx+br < box_x-box_w then
		return false
	end
	if by+br < box_y-box_h then
		return false
	end
	if bx-br > box_x+box_w then
		return false
	end
	if by-br > box_y+box_h then
		return false
	end
	return true
end

function ball_deflx(bx,by,bdx,bdy,tx,ty,tw,th)
	if bdx == 0 then
		--moving horizontally
		return false
	elseif bdy == 0 then
		--moving vertically
		return true
	else
		--moving diagonally
		local slp = bdy/bdx
		local cx, cy
		
		if slp>0 and bdx>0 then
			-- moving southwest
			cx = tx-tw-bx
			cy = ty-th-by
			if cx<=0 then
				return false
			elseif cy/cx < slp then
				return true
			else 
				return false
			end
		elseif slp<0 and bdx>0 then
			-- moving northwest
			cx = tx-tw-bx
			cy = ty+th-by
			if cx<=0 then
				return false
			elseif cy/cx < slp then
				return false
			else
				return true
			end
		elseif slp>0 and bdx<0 then
			-- moving northeast
			cx = tx+tw-bx
			cy = ty+th-by
			if cx>=0 then
				return false
			elseif cy/cx > slp then
				return false
			else
				return true
			end
		else
			-- moving southeast
			cx = tx+tw-bx
			cy = ty-th-by
			if cx>=0 then 
				return false
			elseif cy/cx < slp then
				return false
			else
				return true
			end
		end
	end
	return false
end


-->8
-- bricks --

function ibrick()
	
	bspawn = {}
	
	bspawn.x=15
	bspawn.y=25

	brick = {}
	
	brick.x=bspawn.x
	brick.y=bspawn.y
	brick.w=3
	brick.h=1
	brick.col=12
	
	bricks = {}
	
	pat = 'b1/b2/b3/b4/b5'
	
	gen_bricks(pat)
	
end

function gen_bricks(pat)

	for c in all(pat) do
		if c == 'b' then
			b = {}
			
			b.x=brick.x
			b.y=brick.y
			b.w=brick.w
			b.h=brick.h
			b.col=brick.col
			add(bricks,b)
			brick.x+=(brick.w*2)+2
			
		elseif c == '/' then
			brick.x=bspawn.x
			brick.y+=(brick.h*2)+2
		elseif c>='2' and c<='9' then
			for i=1,c-1 do
				b = {}
			
				b.x=brick.x
				b.y=brick.y
				b.w=brick.w
				b.h=brick.h
				b.col=brick.col
				add(bricks,b)
				brick.x+=(brick.w*2)+2
			end
		end
	end
	
end

function dbricks()
	for b in all(bricks) do
		rectfill(b.x-b.w,b.y-b.h,b.x+b.w,b.y+b.h,b.col)
	end
end
-->8
-- game --

function igame()
	
	game = {}
	
	game.state = 'play'
	game.level = 1
	game.walls = 10
	game.ceil = 8
	game.timer = 0
	
	parts = {}
	
	gravity = .03
	wind = .05
	
end

function dbounds()

	-- walls --
	rectfill(0,0,game.walls,127,5)
	rectfill(127-game.walls,0,127,127,5)
	
	-- ceiling --
	rectfill(0,0,127,game.ceil,9)
end

-- update play state --
function uplay()
	upaddle()
	uball()
end

-- draw play state --
function dplay()
	dbounds()
	dpaddle()
	dball()
	dbricks()
end
-->8
-- levels --
-->8
-- credits --

--[[ 
				
teamwork cast / lazy devs
	
		collision code
		brick generation
				
]]--
-->8
-- to do --

--[[
	
	1 - generate bricks
	2 - brick collision
	2.5 - brick shifting
	3 - lives
	4 - levels
	5 - particles
	6 - music/sfx
	7 - title screen
	8 - credits screen
	
	9 - 
	
]]--
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
