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
	imenu()
	icredits()
	debug=nil
	camera(0,0)
end

function _update60()
	ugame()
	if game.state=='menu' then
		umenu()
	elseif game.state=='play' then
		uplay()
	elseif game.state=='win' then
		uwin()
	elseif game.state=='load' then
		uload()
	elseif game.state=='lose' then
		ulose()
	elseif game.state=='end' then
		uend()
	end
end

function _draw()
	cls()
	if game.state=='menu' then
		dmenu()
	elseif game.state=='play' then
		dplay()
	elseif game.state=='lose' then
		dlose()
	elseif game.state=='win' then
		dwin()
	elseif game.state=='load' then
		dload()
	elseif game.state=='end' then
		dend()
	end

	--debug=pull.power*(pull.power-(pull.decay*10))^abs(pdl.x-ball.x)
	
	--[[fillp(░)
	line(pdl.x-pdl.w,pdl.y-pdl.h,pdl.x-pdl.w,0,7)
	line(pdl.x+pdl.w,pdl.y-pdl.h,pdl.x+pdl.w,0,7)
	fillp()]]
	
	--debug = mag.power
	if debug!=nil then
		print(debug,0,0)
	end
	
	
	
	
	
end
-->8
-- paddle --

-- init paddle --
function ipaddle()

	pdl = {
		col=12,
		sprite=20,
		acc=.35,
		max_spd=3,
		friction=0.1,
		x=63,
		y=115,
		dx=0,
		w=11.5,
		h=1,
		bounce=-0.35,
		state='normal',
		effect=0
		}
		
	mag = {
		active=true,
		power=0,
		acc=0.05,
		decay=0.01,
		max_pwr=1
	}
	
	magnet = {
		
		-- max height
		maxh=120,
		
		-- max width
		maxw=0.05,
		
		col = {
			pal(1,128)
		}
		
		
	}
		
end

-- update paddle --
function upaddle()

 -- player controls --

 if btn(➡️) then
 	pdl.dx+=pdl.acc
 	if pdl.dx>pdl.max_spd then
 		pdl.dx=pdl.max_spd
 	end
 end

 if btn(⬅️) then
 	pdl.dx-=pdl.acc
 	if pdl.dx< -pdl.max_spd then
 		pdl.dx= -pdl.max_spd
 	end
 end
 
 if mag.power>0 then
 	mag.power-=mag.decay
 elseif mag.power<0 then
 	mag.power+=mag.decay
 end
 
 if abs(mag.power)<mag.decay then
 	mag.power=0
 end
 
 if btn(🅾️) and mag.active==true then
 	mag.power+=mag.acc
 	
 	--loop magnet sfx
 	if game.timer%45==1 then
 		sfx(34)
 	end
 	
 	if mag.power>mag.max_pwr then
 		mag.power=mag.max_pwr
 	end
 end
 
	if abs(pdl.dx) < pdl.friction then
		pdl.dx=0
	elseif pdl.dx>0 then
		pdl.dx-=pdl.friction
	elseif pdl.dx<0 then
		pdl.dx+=pdl.friction
	end

 pdl.x+=pdl.dx
 
 -- right wall bounds --
	if pdl.x + pdl.w + 1 >= 
				127 - game.walls then
				
		pdl.dx*=pdl.bounce
		pdl.x = 126 - pdl.w - game.walls
	end
 	
 -- left wall bounds --
	if pdl.x - pdl.w - 1 <=
				game.walls then
		pdl.dx*=pdl.bounce
		pdl.x = 1 + pdl.w + game.walls
	end	
 
 if pdl.effect>0 then
 	pdl.effect-=1
 else
 	pdl_state('normal')
 end
 
 
 
 -- update magnet vxf
 umag_vfx()
 
end

function pdl_state(state)
	if state == 'hurt' then
 	pdl.col=8
 	pdl.effect+=60
 elseif state == 'bounce' then
 	pdl.col=7
 	pdl.effect+=10
 elseif state == 'normal' then
 	if player.lives<=1 then
 		if btn(🅾️)==true then
 			pdl.col = 10
 		else
 			pdl.col=9
 		end
 		
 	else --
 		if btn(🅾️)==true then
 			pdl.col = 12
 		else
 			pdl.col=14
 		end
 	end
 end
end

-- draw paddle --
function dpaddle()

	--[[rectfill(
		pdl.x-pdl.w,
		pdl.y-pdl.h,
		pdl.x+pdl.w,
		pdl.y+pdl.h,
		pdl.col
		)]]
		if game.diff=='easy' then
			spr(20,pdl.x-pdl.w,pdl.y,4,1)
			line(pdl.x-pdl.w+4,pdl.y-pdl.h+2,
						pdl.x+pdl.w-4,pdl.y-pdl.h+2,
						pdl.col)
		
		elseif game.diff=='hard' then
			spr(4,pdl.x-pdl.w,pdl.y,3,1)
		else
		
		end
		
		line(pdl.x-pdl.w+3,pdl.y-pdl.h+1,
							pdl.x+pdl.w-3,pdl.y-pdl.h+1,
							pdl.col)
		
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
	ball.ang=1
	ball.mag=mag.power*(mag.power-(mag.decay*8))^abs(pdl.x-ball.x)
		
end

-- reset ball --
function rball()
	ball.x = pdl.x
	ball.y=pdl.y-ball.r-pdl.h-1
	ball.dy = -1
	ball.state = 'sticky'
end

function uball()

	ball.mag=mag.power*(mag.power-(mag.decay*6))^abs(pdl.x-ball.x)
	--hold ball
	if ball.state == 'sticky' then
		mag.power=0
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
	
	--if ball.x>pdl.x-pdl.w and ball.x<pdl.x+pdl.w then
		
		new_y+=ball.mag
	--end
	
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
		new_y = 1+game.ceil+ball.r
		ball.dy*=-1
		sfx(1)
		
	-- ball falls --
	elseif new_y+ball.r>=127 then
		sfx(3)
		b_streak=0
		pdl_state('hurt')
		ifwork(hearts[#hearts].x,hearts[#hearts].y,8,75)
		deli(hearts,#hearts)
		player.lives-=1
		player.score-=ceil(player.score*.1)
		shake+=.20
		if player.lives==1 then
			shake+=.3
		end
		rball()
	end
	
	-- bounce paddle --
	if ball_hits(new_x,new_y,ball.r,pdl.x,pdl.y,pdl.w,pdl.h) then
		if ball_deflx(ball.x,ball.y,ball.dx,ball.dy,pdl.x,pdl.y,pdl.w,pdl.h) then
			ball.dx *= -1
		else
			ball.dy *= -1
			if ball.y>pdl.y then
				new_y=pdl.y+pdl.h+ball.r
			else
				pdl_state('bounce')
				new_y=pdl.y-pdl.h-ball.r
				--[[if abs(pdl.dx)>2 then
					if sign(pdl.dx)==sign(ball.dx) then
						setang(mid(0,ball.ang-1,2))
					else
						setang(mid(0,ball.ang+1,2))
					end
				end]]
			end
		end
		sfx(2)
		b_streak=0
	end

	ball.x=new_x
	ball.y=new_y
	
	if ceil(rnd(6)) == 6 then
		ball_parts(ball.x,ball.y,ball.dx,ball.dy)
	end
	
	if b_streak>=16 then
		ball.col=12
	else
	 ball.col=7
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

function setang(ang)
	ball.ang=ang
	if ang==2 then
		ball.dx=0.50*sign(ball.dx)
		ball.dy=1.30*sign(ball.dy)
	elseif ang==0 then
		ball.dx=1.30*sign(ball.dx)
		ball.dy=0.50*sign(ball.dy)
	else
		ball.dx=1*sign(ball.dx)
		ball.dy=1*sign(ball.dy)
	end
end

function sign(n)
 if n<0 then
  return -1
 elseif n>0 then
  return 1
 else
  return 0
 end
end


-->8
-- bricks --

function ibrick()
	
	bspawn = {}
	
	bspawn.x=game.walls
	bspawn.y=game.ceil+10

	brick = {}
	
	brick.w=4.5
	brick.h=2.5
	brick.minw=0
	brick.minh=0
	brick.maxw=0
	brick.maxh=0
	brick.chg_rt=100
	
	
	
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

	skip=0
	i=1
	
	brick.w=4.5
	brick.h=2.5
	brick.minw=bspawn.minw
	brick.minh=bspawn.minh
	brick.maxw=bspawn.maxw
	brick.maxh=bspawn.maxh

	for c in all(pat) do
	
		if skip>0 then
			skip-=1
			
		elseif c == 'b' then
			b = {}
			
			b.x=brick.x
			b.y=brick.y
			b.w=brick.w
			b.h=brick.h
			b.minw=brick.minw
			b.minh=brick.minh
			b.maxw=brick.maxw
			b.maxh=brick.maxh
			b.col=brick.col
			b.chg_rt=brick.chg_rt
			add(bricks,b)
			brick.x+=(brick.w*2)+2
			
		elseif c == '/' then
			brick.x=bspawn.x
			brick.y+=(brick.h*2)+2
			brick.col+=1
		
		elseif c == '-' then
			brick.x+=(brick.w*2)+2
			
		elseif c=='c' then
			if pat[i+2]>='0' and pat[i+2]<='9' then
				brick.col=10+pat[i+2]
				skip+=1
			else
				brick.col=pat[i+1]
			end
			skip+=1
			
		elseif c == 'w' then
			brick.w=pat[i+1]
			skip+=1
			
		elseif c == 'h' then
			brick.h=pat[i+1]
			skip+=1
			
		elseif c=='m' then
			local n = tonum(pat[i+3])
		
			if pat[i+1]=='n' then
				if pat[i+2]=='w' then
					brick.minw=n
				elseif pat[i+2]=='h' then
					brick.minh=n
				end
				
			elseif pat[i+1]=='x' then
				if pat[i+2]=='w' then
					brick.maxw=n
				elseif pat[i+2]=='h' then
					brick.maxh=n
				end
			end
			skip+=3
			
		elseif c>='2' and c<='9' then
			for i=1,c-1 do
				b = {}
			
				b.x=brick.x
				b.y=brick.y
				b.w=brick.w
				b.h=brick.h
				b.minw=brick.minw
				b.minh=brick.minh
				b.maxw=brick.maxw
				b.maxh=brick.maxh
				b.chg_rt=brick.chg_rt
				b.col=brick.col
				add(bricks,b)
				brick.x+=(brick.w*2)+2
			end
		end
		i+=1
	end
	
	center_bricks()
end

function center_bricks()

	if #bricks<=0 then
		return
	end
	
	local b1 = bricks[1]
	local min_x=b1.x-b1.w
	local max_x=b1.x+b1.w
	
	for b in all(bricks) do
	
		if b.x-b.w<min_x then
			min_x=b.x-b.w
		elseif b.x+b.w>max_x then
			max_x=b.x+b.w
		end
		
	end
	

	local sides = (128-(max_x-min_x))/2
	offset = sides-min_x
	
	for b in all(bricks) do
		b.x+=offset
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
			if b_streak<=3 then
				b_sfx=25
			elseif b_streak<=5 then
				b_sfx=26
			elseif b_streak<=6 then
				b_sfx=27
			elseif b_streak<=10 then
				b_sfx=28
			elseif b_streak<=13 then
				b_sfx=29
			elseif b_streak>=15 then
				b_sfx=30
				if b_streak%5==0 then
					local x = b.x
					local y = b.y
					local c = b.col
					local mag = 50+(game.level*20)
					local vel = 3+(game.level*.25)
					ifwork(x,y,c,mag,vel)
					ifwork(x,y,c+1,mag/2,vel/1.5)
					
					shake+=.09
					sfx(33)
				end
			end
			sfx(b_sfx)
			brick_parts(b.x,b.y,b.w,b.h)
			del(bricks, b)
			
			if b_streak>=15 and
				b_streak%5==0 then
				
				for i=0,flr(b_streak/5) do
					if #bricks>0 then
						player.score+=1*b_streak
						b2=bricks[ceil(rnd(#bricks))]
						brick_parts(b2.x,b2.y,b2.w,b2.h)
						del(bricks, b2)
					end
				end
				
			end
			
			b_hit+=1
			b_streak+=1
			player.score+=1*b_streak
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
	if ball.state=='sticky' then
		return
	end
	if #bricks < b.chg_rt then
		b.chg_rt=#bricks
	end
	if ceil(rnd(b.chg_rt))!=b.chg_rt then
		return
	end
	
	change = ceil(rnd(8))
	if change == 1 and btn(➡️) then
		b.x+=1
	elseif change == 2 and btn(⬅️) then
		b.x-=1
	elseif change == 3 and ball.dy>0 then
		b.y+=1
	elseif change == 4 and ball.dy<0 then
		b.y-=1
	elseif change == 5 then
		b.w+=.5
		if b.w > b.maxw then
			b.w = b.maxw
		end
	elseif change == 6 then
		b.w-=.5
		if b.w < b.minw then
			b.w = b.minw
		end
	elseif change == 7 then
		b.h+=.5
		if b.h > b.maxh then
			b.h = b.maxh
		end
	elseif change == 8 then
		b.h-=.5
		if b.h < b.minh then
			b.h = b.minh
		end
	end
	
	if b.x-b.w < game.walls+1 then
		b.x = 1+game.walls+b.w
	elseif b.x+b.w > 126 - game.walls then
		b.x = 126 - game.walls - b.w
	end
	
	if b.y-b.h < game.ceil+1 then
		b.y = game.ceil + b.h +1
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
	game.tlvls = 5
	game.walls = 2
	game.spwalls = 2
	game.mwalls = 24
	game.ceil = 8
	game.ceilc = 6
	game.timer = 0
	game.display = false
	
	--difficulty
	game.diff = 'easy'
	
	player = {}
	
	player.lives = 5
	player.lost = 0
	player.score = 0
	hurt=10
	
	parts = {}
	
	gravity = .03
	wind = .05
	shake = 0
	shake_lvl = 32
	
	pal(4,12+128,1)
	pal(3,1+128,1)
	pal(13,3+128,1)
	pal(14,12+128,1)
	pal(15,6+128,1)
	
end

-- game state machine --
------------------------
function ugame()
	if game.state=='menu' then
		if btnp(❎) then
			iload(game.level)
		end
	elseif game.state=='play' then
		if player.lives<=0 then
			ilose()
		elseif #bricks==0 then
			iwin(game.level)
		end
	elseif game.state=='win' then
		if btnp(❎) then
			game.level+=1
			iload(game.level)
		end
	elseif game.state=='end' then
		if btnp(❎) and #a_credits==#credits then
			_init()
		end
	elseif game.state=='lose' then
		if btnp(❎) then
			player.lives=1
			iload(game.level)
		end
	elseif game.state=='load' then
		game.timer+=1
		if game.timer==60 then
			game.timer=0
			game.state='play'
		end
	end
end


-- play state --
----------------

-- init play state
function iplay()
	game.state = 'play'
end

-- update play state
function uplay()
	uhelp()
	uwind()
	udrip()
	uclouds()
	upaddle()
	screen_shake()
	uball()
	ubricks()
	uparts()
	ufworks()
	uhearts()
	if game.timer > 15 then
		banner.bgc = 4
		banner.textc = 7
		uscore()
	end
	game.timer+=1
end

-- draw play state
function dplay()
	dclouds()
	dparts()
	dmag_vfx()
	ddrip()
	dbounds()
	dbanner()
	dpaddle()
	dball()
	dbricks()
	--dlives()
	dhearts()
	dfworks()
	dhelp()
	--[[if player.hurt>0 then
		fillp(░)
		rectfill(0,game.ceil+1,128,128,5)
		fillp()
		player.hurt-=1
	end]]
end

-- menu state --
----------------

function imenu()
	game.state='menu'
	ihelp()
	center_bnr()
	game.timer=0
	gen_bricks(level[1])
end

function umenu()
	uhelp()
	uclouds()
	screen_shake()
	game.timer+=1
end

function dmenu()
	dclouds()
	dbounds()
	dbricks()
	dhelp()
end

-- load state --
----------------

-- iload function on level page
--	>>>

function uload()
	uclouds()
	uparts()
	ufworks()
	screen_shake()
end

function dload()
	dplay()
end



-- win state --
---------------

-- init win state
function iwin(lvl)
	music(-1)
	sfx(6)
	
	--heart explosions
	for i=0,player.lives do 
		ifwork(8+(i*8),5,8,50)
	end
	
	--ball explosion
	ifwork(ball.x,ball.y,ball.col,75)
	ifwork(ball.x,ball.y,ball.col-1)
	
	game.timer=0
	change_bnr('you win!')
	center_bnr()
	game.state='win'
	
	if lvl == game.tlvls then
		game.state='end'
	end
	
end

--update win state
function uwin()
	uclouds()
	uparts()
	ufworks()
	upaddle()
	uwind()
	screen_shake()
	
	
	if game.timer%(75-(game.level*9))==1 then
		ifwork()
		sfx(31)
	end
	
	if game.timer%(200-(game.level*14))==1 then
		local x = rnd(120)+4
		local y = rnd(120)+4
		local c = 7+ceil(rnd(5))
		local mag = 50+(game.level*20)
		local vel = 3+(game.level*.25)
		
		ifwork(x,y,c,mag,vel)
		ifwork(x,y,c+1,mag/2,vel/1.5)
		
		shake+=.09
		sfx(33)
	end
		
	
	if game.timer==300 and game.state=='win' then
		change_bnr('press ❎')
	elseif game.state=='end' then
		change_bnr('final score: '..player.score)
		center_bnr()
	end
	
	game.timer+=1
	
end

-- draw win state
function dwin()
	dclouds()
	dparts()
	dbounds()
	dbanner()
	dpaddle()
	dfworks()
end

-- end state --
---------------

function iend()
	_init()
end

function uend()
	uwin()
	
	if btnp(❎) then
		
		add(a_credits,
			credits[#a_credits+1]
		)
		
		if credits[#a_credits]=='' then
			add(a_credits,
				credits[#a_credits+1]
			)
		end
	end
end

function dend()
	dwin()
	i=0
	for c in all(a_credits) do
		print(c,game.walls+5,game.ceil+3+(i*6),7)
		i+=1
	end
end

-- lose state --
----------------

-- init lose
function ilose()
	game.state='lose'
	music(-1)
	sfx(5)
	change_bnr('you lose!')
	center_bnr()
	player.score-=ceil(player.score/2)
	game.timer=0
end

-- update lose
function ulose()
	uclouds()
	uparts()
	ufworks()
	uball()
	screen_shake()
	
	if game.timer==150 then
		change_bnr('press ❎')
	end
	game.timer+=1
end

-- draw lose
function dlose()
	dplay()
end



function dbounds()

	-- walls --
	rectfill(-shake_lvl,-shake_lvl,game.walls,127+shake_lvl,5)
	rectfill(127-game.walls,-shake_lvl,127+shake_lvl,127+shake_lvl,5)
	
	-- ceiling --
	rectfill(0,0,127,game.ceil,game.ceilc)
	
	-- floor --
	rectfill(0,126,127,127,game.ceilc)
end



function screen_shake()
	local shakex = (shake_lvl/2) - rnd(shake_lvl)
	local shakey = (shake_lvl/2) - rnd(shake_lvl)
	
	shakex=shakex*shake
	shakey=shakey*shake
	
	camera(shakex,shakey)
	
	shake*=0.95
	
	if shake<0.05 then
		shake=0
	end
	
end
-->8
-- levels --

function ilevel()
	level = {}
	
	level[1] = '//c8h2w1b3-b3-b3-b3-b-b-b3/b-b--b--b---b-b-b-b--b-/b3--b--b---b-b-b-b--b/b----b--b---b-b-b-b--b/b---b3-b3-b3-b3--b'--
	level[2] = 'h2w3//c7-b-----------b/c8-b--b-----b--b/-b2-b-b-b-b-b2/-b2-b-b-b-b-b2/-b2-b-b-b-b-b2/-b2-b-b-b-b-b2/c5-b9b4/c5-b9b4'--
	level[3] = '/c5mxh1mxw1b8mnh5mnw5b/c5b9/c6b9/c14b9/c14b9/c6b9/c5b9/c5b9'--
	level[4] = 'h2w5b9b/b9b/b2------b2/b2------b2/b2------b2/b2------b2/b2------b2/c5b3----b3/c5b4--b4/c5b4--b4/c5--b2--b2--'--
	level[5] = '/c0h3w4b9b2/c0b9b2/c0b3--b--b3/c0b9b2/c0b4---b4/c0b9b2/c0b9b2'--
	level[6] = 'b'--'h2/b8/b7/b6/b5/b4/b3/b2/b1'
	
	--'h4b-b-b-b/-b-b-b-b/b-b-b-b/-b-b-b-b/b-b-b-b/-b-b-b-b/b-b-b-b/-b-b-b-b/'
	--'b3--b3/b3--b3/b3--b3/b3--b3/b3--b3/b3--b3'
	--'/c8w5h3mxh1mxw1b8/b8/b8/b8/mnh5mnw5mxh7mxw7b8/b8'--
end

function iload(lvl)
	game.timer=0
	game.state='load'
	change_bnr('level '..game.level)
 banner.x=95
 banner.y=1
 banner.bgc=7
 banner.textc=5
 game.walls=game.spwalls
 idrip()
 ihelp()
 ibrick()
	ipaddle()
	rball()
	sfx(4,3)
	music(0,5000,2)
	
	if game.level == 0 then
		bspawn.minw=3
		bspawn.minh=1
		bspawn.maxw=5
		bspawn.maxh=3
	
	elseif game.level == 1 then
		
		bspawn.minw=3
		bspawn.minh=2
		bspawn.maxw=5
		bspawn.maxh=3
		
		player.lives=3
		
	elseif game.level == 2 then
	
		
		
		bspawn.minw=2
		bspawn.minh=2
		bspawn.maxw=5
		bspawn.maxh=3
		
		player.lives+=2
		
	
	elseif game.level==3 then
		bspawn.minw=1
		bspawn.minh=1
		bspawn.maxw=3
		bspawn.maxh=2
		
		player.lives+=2
		
	elseif game.level==4 then
		bspawn.minw=1
		bspawn.minh=1
		bspawn.maxw=3
		bspawn.maxh=2
		
		player.lives+=2
		
	elseif game.level==5 then
		bspawn.minw=1
		bspawn.minh=1
		bspawn.maxw=3
		bspawn.maxh=2
		
		player.lives+=2
		
	else
		iend()
	end
	
	
	if game.diff=='easy' then
			pdl.w=15.5
			pdl.spr=20
			pdl.max_spd=4
		elseif game.diff=='hard' then
			pdl.w=11.5
			pdl.spr=4
			pdl.max_spd=3.5
		end

	
	ihearts()
	gen_bricks(level[lvl])
		
end
-->8
-- particles --

function iparts()
	
	parts = {}

	-- clouds
	bg_clouds = {}
	mg_clouds = {}
	fg_clouds = {}
	
	-- fireworks
	fworks = {}
	sm_fwork = 30
	lg_fwork = 45
	
	-- environment fx
	gravity = .03
	wind = .05
	
	-- magnet vfx
	mag_parts = {}
	
	mag_part_maxw = 0
	mag_part_maxh = 0
	max_magparts = 15
	
	drip_parts = {}
	
end

-- update general particles
function uparts()
	
	for p in all(parts) do
		p.l-=1
		if p.l < 0 then
			del(parts,p)
		else
			
			if p.col==7 then
				p.col = 7
			elseif p.l > 200 then
				p.col = 11
			elseif p.l > 125 then
				p.col = 12
			elseif p.l > 100 then
				p.col = 10
			elseif p.l > 50 then
				p.col = 9
			elseif p.l > 25 then
				p.col = 8 
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
	
			-- add gravity pull
			p.dy+=gravity
		
				
			p.x+=p.dx+wind
			p.y+=p.dy

		end
	end
	
	--umag_vfx()
	--udrip()
	
end

function brick_parts(bx,by,bw,bh)
	for i=1,15+(b_streak*2) do
	
		local life=rnd(150)
		
		if b_streak>=16 then
			col=7
		else
			col=12
		end
		
		if b_streak>5 then
			life+=100
		end
		add(parts,{
			x=bx+rnd((bw*2)+1)-bw,
			y=by+rnd((bh*2)+1)-bh,
			dx=rnd(2)-1,
			dy=rnd(2)-1,
			l=life,
			col=col
		})
	end
end

function ball_parts(bx,by,bdx,bdy)
	
	if b_streak>=10 then
		col=7
	else
		col=12
	end
	
	add(parts,{
		x=bx,
		y=by,
		dx=(bdx*-.5)+rnd(1)-.5,
		dy=(bdy*-.5)+rnd(1)-.5,
		l=rnd(100),
		col=col
	})
end

function dparts()

	for p in all(parts) do
		pset(p.x,p.y,p.col)
	end
	
end


function uwind()
	if btn(➡️) then
		wind += 0.02
	end
	if btn(⬅️) then
		wind -= 0.02
	end
	if wind > 0 then
		wind -= 0.005
	elseif wind < 0 then
		wind += 0.005
	end
	wind = mid(-1,wind,1)
	if abs(wind)<0.005 then
		wind=0
	end
end





-- fireworks --
---------------

-- init firework
function ifwork(genx,geny,col,mag,vel)
	if genx==nil then
		genx=rnd(128-(game.walls*2))+game.walls
	end
	if geny==nil then
		geny=rnd(128-game.ceil)+game.ceil
	end
	if col==nil then
		col=7+ceil(rnd(5))
	end
	if mag==nil then
		mag=25
	end
	if vel==nil then
		vel = 3
	end
	local size=rnd(5)
	for i=0,mag+rnd(40) do
		add(fworks,{
			x=genx+(rnd(size)-(size/2)),
			y=geny+(rnd(size)-(size/2)),
			dx=rnd(vel)-(vel/2),
			dy=rnd(vel)-(vel/2),
			l=rnd(100),
			c=col
		})
	end
end

-- update firework particles
function ufworks()

	for fw in all(fworks) do
		fw.l-=1
		if fw.l < 0 then
			del(fworks,fw)
		else
			fw.dy+=gravity
			fw.x+=fw.dx+wind
			fw.y+=fw.dy
		end
		
		if fw.x > 127 then
				fw.x = 127
				fw.dx *= -1
			elseif fw.x < 1 then
				fw.x= 1
				fw.dx *= -1
			end
			if fw.y > 127 or fw.y < 0 then
				fw.dy *= -1
			end
	end
	
end

-- draw firework particles
function dfworks()
	for fw in all(fworks) do
		pset(fw.x,fw.y,fw.c)
	end
end

-- clouds --
------------
function uclouds()

	if #bg_clouds<7 then
	
		if b_streak>=16 then
			col=6
		else
			col=3
		end
		
		add(bg_clouds,{
			x=rnd(64)-128,
			y=rnd(64),
			dx=rnd(1)+.5,
			w=rnd(30)+20,
			h=rnd(5)+4,
			col=col
		})
	end
	
	if #mg_clouds<6 then
	
		if b_streak>=16 then
			col=6
		else
			col=4
		end
		
		add(mg_clouds,{
			x=rnd(64)-128,
			y=rnd(64)+32,
			dx=rnd(1)+.5,
			w=rnd(25)+15,
			h=rnd(4)+2,
			col=col
		})
	end
	
	if #fg_clouds<10 then
	
		if b_streak>=16 then
			col=6
		else
			col=2
		end
		
		add(fg_clouds,{
			x=rnd(64)-128,
			y=rnd(64)+64,
			dx=rnd(2)+1,
			w=rnd(25)+15,
			h=rnd(3)+2,
			col=col
		})
	end
	
	for c in all(bg_clouds) do
		if c.x-c.w>128-game.walls then
			del(bg_clouds,c)
		else
			c.x+=c.dx+wind
		end
	end
	
	for c in all(mg_clouds) do
		if c.x-c.w>128-game.walls then
			del(mg_clouds,c)
		else
			c.x+=c.dx+wind
		end
	end
	
	for c in all(fg_clouds) do
		if c.x-c.w>128-game.walls then
			del(fg_clouds,c)
		else
			c.x+=c.dx+wind
		end
	end

end

function dclouds()

	for c in all(bg_clouds) do
		rectfill(c.x-c.w,c.y-c.h,c.x+c.w,c.y+c.h,c.col)
	end
	
	for c in all(mg_clouds) do
		rectfill(c.x-c.w,c.y-c.h,c.x+c.w,c.y+c.h,c.col)
	end
	
	for c in all(fg_clouds) do
		rectfill(c.x-c.w,c.y-c.h,c.x+c.w,c.y+c.h,c.col)
	end
	
end

-- magnet particles --
----------------------

-- update mag particles
function umag_vfx()
	
	if mag.power>0 then
		if #mag_parts < max_magparts and
					game.timer%10==0 and
					btn(🅾️) then
					
			 add(mag_parts,
			 	{
			 		x=ball.x,
			 		y=ball.y,
			 		
			 		dx=rnd(1)-0.5,
			 		dy=rnd(1)-0.5,
			 		
			 		r=1+rnd(3),
			 		w=rnd(3),
			 		h=pdl.h+rnd(3),
			 		col=ceil(rnd(3)+13)}
			 )
		end
		
		for m in all(mag_parts) do
		
		
			
			if mag.active==true then
			
					if m.x<pdl.x then
						m.dx+=mag.power/80
					elseif m.x>pdl.x then
						m.dx-=mag.power/80
					end
					
					if m.y<pdl.y then
						m.dy+=mag.power/80
					elseif m.y>pdl.y then
						m.dy-=mag.power/80
					end
					
			end
		end
		
	end
	

	
	for m in all(mag_parts) do
		if m.x+30<game.walls or
				m.x-30>127-game.walls or
				m.y-30>127 or
				m.y+30<0 then
			del(mag_parts,m)
		end
		
		m.x+=m.dx+(pdl.dx/5)+(wind/2)
		m.y+=m.dy
			
	end
	
end

function dmag_vfx()

 --[[for m in all(mag_parts) do
		--[[rect(m.x-m.w,
			m.y-m.h,
			m.x+m.w,
			m.y+m.h,
			m.col)
		circ(m.x,
			m.y,
			m.r,
			m.col)
	end]]
	
	

end

function idrip()
	for i in all(drip_parts) do
		del(drip_parts, i)
	end
end

function udrip()
	if btn(🅾️) then
		if game.timer%3==0 then
					
			local col=7
			if b_streak>=15 then
				col=12
			end
			add(drip_parts,{
				x=ball.x,
				y=ball.y+ball.r-1,
				t=0,
				life=20+ceil(rnd(60)),
				h=0,
				col=col
			})
		end
	end
	
	for d in all(drip_parts) do
		d.t+=1
		if d.t<d.life/2 then
		 d.h+=mag.power/5
		elseif d.t<d.life then
			d.h-=mag.power/5
		else
			del(drip_parts,d)
		end
		
		d.y+=mag.power/10
		
	end
end

function ddrip()
	for d in all(drip_parts) do
		line(d.x,d.y,d.x,d.y+d.h,d.col)
	end
end
-->8
-- notif banner --

function ibanner()
	banner = {}
	
	banner.x = 18
	banner.y = 68
	banner.w = 17
	banner.h = 6
	banner.bgc = 4
	banner.textc = 7
	banner.l = banner.x+banner.w
	banner.r = banner.l
	banner.notif = 'level '..game.level

	hearts = {}
	
	help = {}
	
	help.state = 'serve'
	help.msg = 'press ❎/x to serve ball'
	help.x = 30
	help.y = 63
	help.w = 0
	help.textc = 7
	help.timer = 0
	
end

function ihelp()
	
	help.timer=0
	if game.state == 'menu' then
		help.state = 'menu'
		change_help('press ❎/x to start')
	elseif game.level==1 then
		help.state = 'serve'
		change_help('press ❎/x to serve ball')
	elseif game.level==2 then
		help.state = 'tip'
	elseif game.level==3 then
		help.state = 'tip'
	elseif game.level==4 then
	 help.state = 'tip'
	elseif game.level==5 then
		help.state = 'tip'
	end
	
end

function uhelp()
	if help.state == 'serve' then
		if btn(❎) then
			help.state = 'magnet'
			change_help('hold 🅾️/c to activate magnet')
		end
	elseif help.state == 'magnet' then
		if btn(🅾️) then
			help.timer+=1
			if help.timer>=120 then
				help.state = 'good luck!'
				change_help('good luck!')
				help.timer = 0
			end
		end
	elseif help.state=='good luck!' then
		help.timer+=1
		if help.timer > 300 then
			help.state='none'
			help.msg=nil
			help.timer=0
		end
	end
end

function change_help(text)
	help.msg=text
	help.w=#help.msg*4
	for c in all(text) do
		if c == '❎' or c=='🅾️' then
			help.w+=4
		end
	end
	
	-- center help
	help.x=(128-help.w)/2
end

function dhelp()
	if help.msg != nil then
		print(help.msg,help.x,help.y,help.textc)
	end
end

-- update score
function uscore()
	banner.notif=player.score
end

function change_bnr(text)
	banner.notif=text
	banner.w=#banner.notif*4
	for c in all(text) do
		if c == '❎' then
			banner.w+=4
		end
	end
end

function center_bnr()
	banner.x=(128-banner.w)/2
end

function dbanner()
	rectfill(banner.x,banner.y,banner.x+banner.w,banner.y+banner.h,banner.bgc)
	print(banner.notif,banner.x+1,banner.y+1,banner.textc)
end

-- hearts --
------------

function ihearts()

	heart = {}
	
	heart.x = 0
	heart.y = 0
	heart.spr = 3
	
	-- animation timer
	heart.anim_t = 15
	-- animation stage
	heart.anim_stg = 0
	
	for h in all(hearts) do
		del(hearts,h)
	end
	
	for i=1, player.lives do
		
		h={}
		
		h.x=heart.x
		h.y=heart.y
		h.spr=heart.spr
		h.anim_t=heart.anim_t
		h.anim_stg=heart.anim_stg
		
		heart.x+=8
		heart.anim_t+=5
		
		add(hearts,h)
	end
	
end

function uhearts()
	
	for h in all(hearts) do
		h.anim_t-=1
		h.anim_t-=b_streak/5
		
		-- blue hearts during streak
		if b_streak>=16 and
					h.spr==0 then
			h.spr+=16
		elseif b_streak<16 and
									h.spr>=16 then
			h.spr-=16
		end
		
		if h.anim_t<=0 then
			local stage = h.anim_stg
			if stage==0 then
				h.spr-=1
				if h.spr==0 or h.spr==16 then
					h.anim_stg=1
					h.anim_t+=25
					h.y+=1
				else
					h.anim_t+=15
				end
			elseif stage==1 then
				h.spr+=1
				if h.spr==2 or h.spr==18 then
					h.anim_stg=0
					h.anim_t+=10
					h.y-=1
				else
					h.anim_t+=15
				end
			end
		end
	end
	
end

function dhearts()
	for h in all(hearts) do
		spr(h.spr,h.x,h.y)
	end
end


-->8
-- to do --

--[[

	1 - better level for 3
						
	3 - title song
	
	4 - tweak game loop song
	
					
	5 - "press 🅾️ to activate magnet"
					displayed in level 1
					
					"press ❎ to serve ball"
					displayed when ball is sticky
						for too long
	
	
	ideas
	
	special powers
	-charged blast
		
		player holds ❎ to charge
		upward blast, but they cannot
		move while charging
		
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

function icredits()
	a_credits = {credits[1]}
end

credits = {
	'picout',
	'',
	'created by',
	'	ripe jalapeno studios',
	'',
	'special thanks to',
	' krystian majewski',
	'	from lazy devs academy',
	'	for collision code',
	'	and brick generation',
	'',
	'thanks for playing!'
	}
	

	 
__gfx__
00000000000000000000000000000000066cccccccccccccccccc660000000000000000000000000000000000000000000000000000000000000000000000000
00880880000888000000800000000000d6000000000000000000006d000000000000000000000000000000000000000000000000000000000000000000000000
08888888008888800008880000000000dd66660000000000006666dd000000000000000000000000000000000000000000000000000000000000000000000000
088888880088888000088800000000000ddd6666666666666666ddd0000000000000000000000000000000000000000000000000000000000000000000000000
00888880000888000008880000000000000dddddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000
00088800000888000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008000000080000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000066000000000000000000000000006600000000000000000000000000000000000000000000000000000000000000000
00990990000999000000900000000000d666600000000000000000000006666d0000000000000000000000000000000000000000000000000000000000000000
09999999009999900009990000000000dd66660000000000000000000666666d0000000000000000000000000000000000000000000000000000000000000000
099999990099999000099900000000000d666000000000000000000000666dd00000000000000000000000000000000000000000000000000000000000000000
0099999000099900000999000000000000dd66666660000000006666666dd0000000000000000000000000000000000000000000000000000000000000000000
000999000009990000009000000000000000dddddd666666666666ddddd000000000000000000000000000000000000000000000000000000000000000000000
00009000000090000000900000000000000000000ddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000ddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66688866666888666666866666666666666666666666666666666666666666666666666666666666666666666666666lllllllllllllllllllllllllllll6666
66888886668888866668886666666666666666666666666666666666666666666666666666666666666666666666666l7lll777l7l7l777l7lllllll77ll6666
66888886668888866668886666666666666666666666666666666666666666666666666666666666666666666666666l7lll7lll7l7l7lll7llllllll7ll6666
66688866666888666668886666666666666666666666666666666666666666666666666666666666666666666666666l7lll77ll7l7l77ll7llllllll7ll6666
66688866666888666666866666666666666666666666666666666666666666666666666666666666666666666666666l7lll7lll777l7lll7llllllll7ll6666
66668666666686666666866666666666666666666666666666666666666666666666666666666666666666666666666l777l777ll7ll777l777lllll777l6666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666lllllllllllllllllllllllllllll6666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
50000000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5
50000000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5
50000000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5
50000000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5
50000000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5
50000000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5
50000000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5
50000000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5
500000000000000000000000000000000000000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh5
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhh999h999h999hhhhh999h999h999hhhhh999h999099900000999099909990000099900000999000009990999099900000000000000000000000000005
5hhhhhhh989h989h989hhhhh989h989h989hhhhh989h989098900000989098909890000098900000989000009890989098900000000000000000000000000005
5hhhhhhh989h989h989hhhhh989h989h989hhhhh989h989098900000989098909890000098900000989000009890989098900000000000000000000000000005
5hhhhhhh989h989h989hhhhh989h989h989000009890989098900000989098909890000098900000989000009890989098900000000000000000000000000005
5hhhhhhh999h999h999hhhhh999h999h999000009990999099900000999099909990000099900000999000009990999099900000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhaaahhhhhaaahhhhhhhhhaaahh0000000aaa0000000000000aaa00000aaa00000aaa00000aaa000000000aaa000000000000000000000000000000005
5hhhhhhha9ahhhhha9ahhhhhhhhha9ahh0000000a9a0000000000000a9a00000a9a00000a9a00000a9a000000000a9a000000000000000000000000000000005
5hhhhhhha9ahhhhha9ahhhhhhhhha9ahh0000000a9a0000000000000a9a00000a9a00000a9a00000a9a000000000a9a000000000000000000000000000000005
5hhhhhhha9ahhhhha9ahhhhhhhhha9ahh0000000a9a0000000000000a9a00000a9a00000a9a00000a9a000000000a9a000000000000000000000000000000005
5hhhhhhhaaahhhhhaaahhhhhhhhhaaahh0000000aaa0000000000000aaa00000aaa00000aaa00000aaa000000000aaa000000000000000000000000000000005
5hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
5hhhhhhhbbbhbbbhbbbhhhhhhhhhbbbhh0000000bbb0000000000000bbb00000bbb00000bbb00000bbb000000000bbb000000000000000000000000000000005
5hhhhhhhbabhbabhbabhhhhhhhhhbabhhhhh0000bab0000000000000bab00000bab00000bab00000bab000000000bab000000000000000000000000000000005
50000000bab0bab0bab000000000bab000000000bab0000000000000bab00000bab00000bab00000bab000000000bab000000000000000000000000000000005
50000000bab0bab0bab000000000bab000000000bab0000000000000bab00000bab00000bab00000bab000000000bab000000000000000000000000000000005
50000000bbb0bbb0bbb000000000bbb000000000bbb0000000000000bbb00000bbb00000bbb00000bbb000000000bbb000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50000000ccc00000000000000000ccc000000000ccc0000000000000ccc00000ccc00000ccc00000ccc000000000ccc000000000000000000000000000000005
50000000cbc00000000000000000cbc000000000cbc0000000000000cbc00000cbc00000cbc00000cbc000000000cbc000000000000000000000000000000005
50000000cbc00000000000000000cbc000000000cbc0000000000000cbc00000cbc00000cbc00000cbc000000000cbc000000000000000000000000000000005
50000000cbc00000000000000000cbc000000000cbc0000000000000cbc00000cbc00000cbc00000cbc000000000cbc000000000000000000000000000000005
50000000ccc00000000000000000ccc000000000ccc0000000000000ccc00000ccc00000ccc00000ccc000000000ccc000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50000000hhh0000000000000hhh0hhh0hhh00000hhh0hhh0hhh00000hhh0hhh0hhh00000hhh0hhh0hhh000000000hhh000000000000000000000000000000005
50000000hch0000000000000hch0hch0hch00000hch0hch0hch00000hch0hch0hch00000hch0hch0hch000000000hch000000000000000000000000000000005
50000000hch0000000000000hch0hch0hch00000hch0hch0hch00000hch0hch0hch00000hch0hch0hch000000000hch000000000000000000000000000000005
50000000hch0000000000000hch0hch0hch00000hch0hch0hch00000hch0hch0hch00000hch0hch0hch000000000hch000000000000000000000000000000005
50000000hhh0000000000000hhh0hhh0hhh00000hhh0hhh0hhh00000hhh0hhh0hhh00000hhh0hhh0hhh000000000hhh000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222222222222222222222000000000000005
50000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222222222222222222222000000000000005
50000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222222222222222222222000000000000005
50000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222222222222222222222000000000000005
50000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222222222222222222222000000000000005
50000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222222222222222222222000000000000005
50000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222222222222222222222000000000000005
50000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222222222222222222222000000000000005
50000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222222222222222222222000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
52222222222222222222222222222222222222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000005
52222222222222222222222222222222222222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000005
52222222222222222222222222222222222222222222000000000000000000000000000002222222222222222222222222222222222222222222222222222225
52222222222222222222222222222222222222222222000000000000000000000000000002222222222222222222222222222222222222222222222222222225
52222222222222222222222222222222222222222222000000000000000000000000000002222222222222222222222222222222222222222222222222222225
52222222222222222222222222222222222222222222000000000000000000000000000002222222222222222222222222222222222222222222222222222225
52222222222222222222222222222222222222222222000000000000000000000000000002222222222222222222222222222222222222222222222222222225
52222222222222222222222222222222222222222222000000000000000000000000000002222222222222222222222222222222222222222222222222222225
52222222222222222222222222222222222222222222000000000000000000000000000002222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000005
50222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000005
50222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000005
50222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000005
50222222222222222222222222222222222222222222222222222222222222222222222200007000000000000000000000000000000000000000000000000005
50222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000005
50222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000005
50222222222222222222222222222222222222222222222222222222222222222222222200000000000000002222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000070000000000000002222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222225
52222222222200000000000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222225
52222222222200000000000000000000000000000000000000000000000000000000700000000000000000002222222222222222222222222222222222222225
52222222222200000000000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222225
52222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
52222222222200000000000000000000000000000000000000000000000000777000000000000000000000000000000000000000000000000000000000000005
52222222222200000000000000000000000000000000000000000000000007777700000000000000000000000000000000000000000000000000000000000005
52222222222200000000000000000000000000000000000000000000000007777700000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000007777700000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000777000000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
500000000000000000000000000000000000000000000000000066cccccccccccccccccc66000000000000000000000000000000000000000000000000000005
500000000000000000000000000000000000000000000000000h6000000000000000000006h00000000000000000000000000000000000000000000000000005
500000000000000000000000000000000000000000000000000hh66660000000000006666hh22222222222222222222222222222222222222222222222222225
5000000000000000000000000000000000000000000000000000hhh6666666666666666hhh222222222222222222222222222222222222222222222222222225
500000000000000000000000000000000000000000000000000000hhhhhhhhhhhhhhhhhh22222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222222222222222222222222222222225
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005

__sfx__
4801000024510275202b530305403554038550335402e52029510235101d51019510135100f5100c5100851006510045100150000500005000050000400000000000000000000000000000000000000000000000
00010000270302503027030280202a0102c0102e0502f0501c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000014720197301e730257402b7402a7401f7001e7001c7000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
d1030000336532b64327623236231f6231b6131461313603000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
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
611000000033300003000030000327620276002760000003003330000300333000031b620000000f6000f6510033300003000030000327620000032760000003003330000300003000031b620000030033300003
d11000001c7511c7511c7511c7511c7511c7511c7511c7511d7511d7511d7511d7511d7511d7511d7511d7511d7511d7511d7511d7001a7501a7511a7511b7002275022751227511a70021750217512175121751
d11000001f7411f7411f7411f7411f7411f7411f7411f7411b7401b7401b7401b7401a7401a7401a7401a7402274121741217411f7401f7401f7401f7401f7401d7401d7401d7401d7401f7401f7401374013740
d71000001c7411c7411c7411c7411d7411d7411f7411f7411d7411d7411d7411d7411c7411c7411c7411c741187411874118741187401b7411b7411d7411d7401a7411a7411a7411a74018741187411874118741
d71000001f7411f7411f7411f74121741217412474124741217412174121741217411f7411f7411f7411f7411c7411c7411c7411c7401d7411d7411f7411f7401d7411d7411d7411d7401c7411c7411c7411c741
d7100000247412474124741247412674126741287412874126741267412674126741247412474124741247411f7411f7411f7411f74021741217412474124740217412174121741217401f7411f7411f7411f741
d1100000247212472124731247312473124731247312473124730247302473024730247202472024720247101c7001d7001d7001c7001c7001c7001c7001c7001670016700167001670015700157001370013700
d1100000287212872128731287312873128731287312873128730287302873028730287202872028720287101c7001d7001d7001c7001c7001c7001c7001c7001670016700167001670015700157001370013700
4801000024510275202b530305403554038550335402e52029510235101d51019510135100f5100c5100851006510045100150000500005000050000400000000000000000000000000000000000000000000000
4801000025510285202d530315403654039550355402f5202b510245101e5101a51014510115100d5100951006510055100351000500005000050000400000000000000000000000000000000000000000000000
4801000027510295202f53033540385403b55037540315202c51025510205101b51016510135100f5100a51009510075100551002510005000050000400000000000000000000000000000000000000000000000
48010000285102a5203053034540395403c55038540325302d52026520215101c5101751014510105100c5100a510085100651003510015000a500135001c500235002e5002d50001500015002b5000000000000
480100000b5101853027540325503a5503d56038550325402c530295202652023520205101d5101b510185101551013510105100d51009510045000050000500235002e5002d50001500015002b5000000000000
480100000b5102252033530395403f5503f560395503654035530325202e5202b5202751024510205101d5101851015510105100d5100b51009510055100151000510025000050000500015002b5000000000000
6a03000003113081130d1131111314123191231e12329133321430010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103
3c03000003113081130d1231112314133191331e14329143321531b133151230e1130c1130a113071130611304113001030010300103001030010300103001030010300103001030010300103001030010300103
3c030000091630b1630d14310133161331d1432114325143271532b16333153221431f1331c1231a113161130f1130b1130811303113031130311302103021030010300103001030010300103001030010300103
b7060000290102c01030010320103301034020350203502033020310202e0102c010290102501023010200101e0101c0101c0101b0101b0101c0001d0001f000210102301026010270102a0102d0102e0202e020
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

