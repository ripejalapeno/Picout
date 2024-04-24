pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	igame()
	ilevel()
	ibanner()
	ipaddle()
	iball()
	ibrick()
	iparts()
	gen_bricks(level[1])
	iplay()
end

function _update60()
	ugame()
	if game.state == 'play' then
		uplay()
	elseif game.state == 'win' then
		uwin()
	elseif game.state == 'load' then
		uload()
	end
end

function _draw()
	cls()
	if game.state == 'play' then
		dplay()
	elseif game.state == 'restart' then
		drestart()
	elseif game.state == 'win' then
		dwin()
	elseif game.state=='load' then
		dload()
	end
	--print(game.state)
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
	ball.y=pdl.y-ball.r-pdl.h-1
	ball.dy = -1
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
		
	-- ball falls --
	elseif new_y+ball.r>=127 then
		player.lives-=1
		sfx(3)
		b_streak=0
		game.walls+=1
		brick_parts(8*player.lives,game.ceil,0,0)
		rball()
	end
	
	-- bounce paddle --
	if ball_hits(new_x,new_y,ball.r,pdl.x,pdl.y,pdl.w,pdl.h) then
		if ball_deflx(ball.x,ball.y,ball.dx,ball.dy,pdl.x,pdl.y,pdl.w,pdl.h) then
			ball.dx *= -1
		else
			ball.dy *= -1
		end
		sfx(2)
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
	
	bspawn.x=game.walls+2
	bspawn.y=game.ceil+10
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
	brick.col=8
	
	bricks = {}
	
	b_hit = 0
	b_streak = 0
	
	--'b6-b/b6-b/b6-b/b6-b/b6-b/b6-b'
	
	
	
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
			brick.col+=1
		
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
			sfx(0)
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
		rect(b.x-b.w,b.y-b.h,b.x+b.w,b.y+b.h,b.col+1)
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
	game.ceilc = 6
	game.timer = 0
	game.display = false
	
	player = {}
	
	player.lives = 3
	
	parts = {}
	
	gravity = .03
	wind = .05
	
	pal(4,5+128,1)
	
end

function ugame()
	if game.state=='play' then
		if player.lives<=0 then
			game.state='restart'
		elseif #bricks==0 then
			iwin(game.level)
		end
	elseif game.state=='win' then
		if btnp(❎) then
			game.level+=1
			iload(game.level)
		end
	elseif game.state=='restart' then
		if btnp(❎) then
			iload(game.level)
			player.lives=3
		end
	elseif game.state=='load' then
		game.timer+=1
		if game.timer==60 then
			game.timer=0
			game.state='play'
			
		--if game.display=='false' then
			--game.state='play'
		end
	end
end

function drestart()
	dplay()
end

function iload(lvl)
	game.state='load'
	banner.notif='level '..game.level
	ibrick()
	ipaddle()
	rball()
	gen_bricks(level[lvl])
end

function uload()
	uparts()
end

function dload()
	dplay()
end


function iwin(lvl)
	music(-1)
	sfx(6)
	if lvl == 3 then
		game.state='end'
		_init()
	else
		game.state='win'
	end
end

function uwin()
	uparts()
end

function dwin()
	dplay()
end

function dbounds()

	-- walls --
	rectfill(0,0,game.walls,127,5)
	rectfill(127-game.walls,0,127,127,5)
	
	-- ceiling --
	rectfill(0,0,127,game.ceil,game.ceilc)
end

function dlives()
	for i=1,player.lives do
		spr(0,(i*8))
	end
end

-- init play state --
function iplay()
	game.state = 'play'
	sfx(4,3)
	music(0,5000)
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
	dbanner()
	dpaddle()
	dball()
	dbricks()
	dlives()
end
-->8
-- levels --

function ilevel()
	level = {}
	
	level[1] = 'b'
	level[2] = 'b2'
	level[3] = 'b6-b/b6-b/b6-b/b6-b/b6-b/b6-b'
end
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
		dx=(bdx*-.5)+rnd(1)-.5,
		dy=(bdy*-.5)+rnd(1)-.5,
		l=rnd(100),
		c=12
	})
end
-->8
-- notif banner --

function ibanner()
	banner = {}
	
	banner.x = 63.5
	banner.y = 4
	banner.w = 15
	banner.h = 3
	banner.bgc = 4
	banner.textc = 7
	banner.l = banner.x+banner.w
	banner.r = banner.l
	banner.notif = 'level '..game.level

end

function ubanner()
	if banner.notif==nil then
		return
	end
end

function dbanner()
	if banner.notif==nil then
		return
	end
	rectfill(banner.x-banner.w,banner.y-banner.h,banner.x+banner.w,banner.y+banner.h,banner.bgc)
	print(banner.notif,banner.x-banner.w+2,banner.y-2,banner.textc)
end
-->8
-- to do --

--[[
	
	1 - congrats for winning level
	
	2 - info banner on top
						to show level number
						and helpful tips
						
						1 - ceiling gets wider
						2 - black rect slides in
						3 - notification slides in
						4 - notif stays a moment
						5 - notif slides out
						6 - rect slides out
						7 - ceiling shrinks to norm
											size again
											
	3 - brick chains
	4 - angle control
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
-- credits --

--[[ 
				
teamwork cast / lazy devs
	
		collision code
		brick generation
				
]]--
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00880880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
4801000024510275202b530305403554038550335402e52029510235101d51019510135100f5100c5100851006510045100150000500005000050000400000000000000000000000000000000000000000000000
00010000270302503027030280202a0102c0102e0502f0501c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000014720197301e730257402b7402a7401f7001e7001c7000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
79020000336502b64027620236201f6201b6101461013600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00000c05010050130501705017050170501705018050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001505015050140501405013050130501205012050120501205012050120501205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
610e0000100501305017050180501f0501c050000000000011050150501a0501d050210501d050000000000013050170501a0501f050230502305023050240002405024050240402404024030240202401024000
011000001805518035180551801518055180351805518015140551405514055140551405514055140551405511055110351105511015110551103511055110150e0550e0550e0550e0550e0550e0550e0550e055
ab10000013055130551305513055130551305513055130551d0551d0351d0551d0151d0551d0351d0551d01515055150551505515055160551605515055150551305513035110551101511035130551105511015
8710000013055130551305513055130551305513055130551d0551d0351d0551d0151d0551d0351d0551d01515055150551505515055160551605515055150551305513035110551101511035130551105511015
4310000013055130551305513055130551305513055130551d0551d0351d0551d0151d0551d0351d0551d01515055150551505515055160551605515055150551305513035110551101511035130551105511015
491000001804518025180451801518045180251804518015180451802518045180151804518025180451801518045180251804518015180451802518045180151801518015180251802518035180351804518045
d11000001c7511c7511c7511c7511c7511c7511c7511c7511d7511d7511d7511d7511d7511d7511d7511d7511d7511d7511d7511d7001b7501b7511b7511b7001a7501a7511a7511a70018750187511875118751
d11000001c7511c7511c7511c7511c7511c7511c7511c75116750167501675016750187501875018750187501c7511d7511d7511c7501c7501c7501c7501c7501d7501d7501d7501d7501f7501f7501375013750
d1100000187511875118751187511875118751187511875118740187401874018740187301873018720187101c7001d7001d7001c7001c7001c7001c7001c7001670016700167001670015700157001370013700
d11000001d7511d7511d7511d7511b7511b7511a7511a751187401874018740187401874018740117501175016750187501a75016750187501875018750187500000000000000000000000000000000000000000
d11000001675016750167501675016750167501675016750157401474013730117301172011720117201173013750137501075010750107501075010750107501074010740107401074010730107301072010720
011000000033300003000030000327630000030000300003003330000300333000031b630000000f6000f6510033300003000030000327630000030000300003003330000300003000031b630000030033300003
d11000001c7511c7511c7511c7511c7511c7511c7511c7511d7511d7511d7511d7511d7511d7511d7511d7511d7511d7511d7511d7001a7501a7511a7511b7002275022751227511a70021750217512175121751
d11000001f7511f7511f7511f7511f7511f7511f7511f7511b7501b7501b7501b7501a7501a7501a7501a7502275121751217511f7501f7501f7501f7501f7501d7501d7501d7501d7501f7501f7501375013750
d71000001c7511c7511c7511c7511d7511d7511f7511f7511d7511d7511d7511d7511c7511c7511c7511c751187511875118751187501b7511b7511d7511d7501a7511a7511a7511a75018751187511875118751
d71000001f7511f7511f7511f75121751217512475124751217512175121751217511f7511f7511f7511f7511c7511c7511c7511c7501d7511d7511f7511f7501d7511d7511d7511d7501c7511c7511c7511c751
d7100000247512475124751247512675126751287512875126751267512675126751247512475124751247511f7511f7511f7511f75021751217512475124750217512175121751217501f7511f7511f7511f751
d1100000247512475124751247512475124751247512475124740247402474024740247302473024720247101c7001d7001d7001c7001c7001c7001c7001c7001670016700167001670015700157001370013700
d1100000287512875128751287512875128751287512875128740287402874028740287302873028720287101c7001d7001d7001c7001c7001c7001c7001c7001670016700167001670015700157001370013700
__music__
01 0b424344
00 07424344
00 07424344
01 07084344
00 07094344
00 070a0c44
00 070a0d44
00 070a0e44
00 070a1244
00 07081344
00 07080e44
00 07081144
00 07091144
00 14081144
00 15081144
00 16141144
02 17181144

