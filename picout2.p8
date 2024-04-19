pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	igame()
	ipaddle()
	iball()
	ibrick()
	iparts()
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
	if new_y-ball.r-1<=game.ceil then
		ball.dy*=-1
		sfx(1)
	elseif new_y+ball.r>=127 then
		ball.dy*=-1
		sfx(1)
		b_streak=0
	end
	
	-- bounce paddle --
	if ball_hits(new_x,new_y,ball.r,pdl.x,pdl.y,pdl.w,pdl.h) then
		if ball_deflx(ball.x,ball.y,ball.dx,ball.dy,pdl.x,pdl.y,pdl.w,pdl.h) then
			ball.dx *= -1
		else
			ball.dy *= -1
		end
		b_streak=0
	end

	ball.x=new_x
	ball.y=new_y
	
	if ceil(rnd(6)) == 6 then
		ball_parts(ball.x,ball.y,ball.dx,ball.dy)
	end
	
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
	
	bspawn.x=10
	bspawn.y=25
	bspawn.minw=3
	bspawn.minh=1
	bspawn.maxw=5
	bspawn.maxh=3

	brick = {}
	
	brick.w=4.5
	brick.h=2.5
	
	bspawn.x+=brick.w
	bspawn.y+=brick.h
	brick.x=bspawn.x
	brick.y=bspawn.y
	brick.col=12
	
	bricks = {}
	
	b_hit = 0
	b_streak = 0
	
	pat = 'b7-b/b7-b/b7-b/b7-b/b7-b/b7-b2'
	
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
		
		elseif c == '-' then
			brick.x+=(brick.w*2)+2
			
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

function ubricks()

	for b in all(bricks) do
		if btn(➡️) or btn(⬅️) then
			shift_brick(b)
		end
		if ball_hits(ball.x,ball.y,ball.r,b.x,b.y,b.w,b.h) then
			if ball_deflx(ball.x,ball.y,ball.dx,ball.dy,b.x,b.y,b.w,b.h) then
				ball.dx *= -1
			else
				ball.dy *= -1
			end
			brick_parts(b.x,b.y,b.w,b.h)
			del(bricks, b)
			b_hit+=1
			b_streak+=1
		end
	end
	
end

function dbricks()
	for b in all(bricks) do
		rectfill(b.x-b.w,b.y-b.h,b.x+b.w,b.y+b.h,b.col)
	end
end

function shift_brick(b)
	--shift
		--up down left right
	if ceil(rnd(60))!=60 then
		return
	end
	
	change = ceil(rnd(8))
	if change == 1 and btn(➡️) then
		b.x+=1
		if b.x+b.w > 126 - game.walls then
			b.x = 126 - game.walls - b.w
		end
	elseif change == 2 and btn(⬅️) then
		b.x-=1
		if b.x-b.w < game.walls-1 then
			b.x = 1+game.walls+b.w
		end
	elseif change == 3 and ball.dy>0 then
		b.y+=1
	elseif change == 4 and ball.dy<0 then
		b.y-=1
		if b.y-b.h < game.ceil then
			b.y = game.ceil + b.h
		end
	elseif change == 5 then
		b.w+=.5
		if b.w > bspawn.maxw then
			b.w = bspawn.maxw
		end
	elseif change == 6 then
		b.w-=.5
		if b.w < bspawn.minw then
			b.w = bspawn.minw
		end
	elseif change == 7 then
		b.h+=.5
		if b.h > bspawn.maxh then
			b.h = bspawn.maxh
		end
	elseif change == 8 then
		b.h-=.5
		if b.h < bspawn.minh then
			b.h = bspawn.minh
		end
	end
	--resize
		--grow shrink
	
end
-->8
-- game --

function igame()
	
	game = {}
	
	game.state = 'play'
	game.level = 1
	game.walls = 16
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
	ubricks()
	uparts()
end

-- draw play state --
function dplay()
	dparts()
	dbounds()
	dpaddle()
	dball()
	dbricks()
	
end
-->8
-- levels --
-->8
-- particles --

function iparts()
	
	parts = {}
	
	gravity = .03
	wind = .05
	
end

function uparts()
	for p in all(parts) do
		p.l-=1
		if p.l < 0 then
			del(parts,p)
		else
		
			if p.l > 125 then
				p.c = 12
			elseif p.l > 100 then
				p.c = 10
			elseif p.l > 50 then
				p.c = 9
			elseif p.l > 25 then
				p.c = 8 
			end
			
			if p.x > 126 - game.walls then
				p.x = 125 - game.walls
				p.dx *= -1
			elseif p.x < game.walls + 1 then
				p.x=game.walls + 2
				p.dx *= -1
			end
			if p.y > 127 or p.y < 0 then
				p.dy *= -1
			end
			
			if ball_hits(p.x,p.y,0,pdl.x,pdl.y,pdl.w,pdl.h) then
				if ball_deflx(p.x,p.y,p.dx,p.dy,pdl.x,pdl.y,pdl.w,pdl.h) then
					p.dx *= -1
				else
					p.dy *= -1
				end
			end
			
			p.dy+=gravity
			p.x+=p.dx+wind
			p.y+=p.dy
			
			if btn(➡️) then
				wind += 0.0005
			end
			if btn(⬅️) then
				wind -= 0.0005
			end
			if wind > 0 then
				wind -= 0.0001
			else
				wind += 0.0001
			end
			wind = mid(-1,wind,1)

		end
	end
end

function dparts()
	for i=1,#parts do
		pset(parts[i].x,parts[i].y,parts[i].c)
	end
end

function brick_parts(bx,by,bw,bh)
	for i=1,10+(b_streak*3) do
		add(parts,{
			x=bx+rnd((bw*2)+1)-bw,
			y=by+rnd((bh*2)+1)-bh,
			dx=rnd(2)-1,
			dy=rnd(2)-1,
			l=rnd(150),
			c=12
		})
	end
end

function ball_parts(bx,by,bdx,bdy)
	add(parts,{
		x=bx,
		y=by,
		dx=(bdx*-1)+rnd(1)-.5,
		dy=(bdy*-1)+rnd(1)-.5,
		l=rnd(100),
		c=12
	})
end
-->8
-- to do --

--[[
	
	3 - lives
	4 - levels
	6 - music/sfx
	7 - title screen
	8 - credits screen
	
	ideas
	
	special powers
	-x to launch paddle in a line
		upward, breaking bricks in
		its path
		
		an outline of the paddle's
		return location will be held
		using rectfill and fillp░
		
	-powerball that tears through
		any bricks it touches, with
		larger radius
	
]]--
-->8

-->8
-- credits --

--[[ 
				
teamwork cast / lazy devs
	
		collision code
		brick generation
				
]]--
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
