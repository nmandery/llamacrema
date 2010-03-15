-- Contains all the balls.
balls = {}
ground = {}
islands = {}
systems = {}
points = 0
llama = {}

function love.load()
    math.randomseed( os.time() )
    love.graphics.setLineWidth(2) -- Fat lines.
	  font = love.graphics.newFont(love._vera_ttf, 20)
	  love.graphics.setFont(font)
	  love.graphics.setColor(200, 200, 200);

    -- Load images.
    images = {
        bg = love.graphics.newImage("img/background.jpg"),
        island = love.graphics.newImage("img/island.png"),
        schlagsahne = love.graphics.newImage("img/schlagsahne.png"),
        part1 = love.graphics.newImage("img/part1.png"),
        llama = love.graphics.newImage("img/llama.png"),
    }
    
    -- Image / radius pairs.
    balldefs = {
		{ i = images.schlagsahne, 	r = 46 , ox = 48, oy = 48},
    }
   
    

    -- Create the world.
    world = love.physics.newWorld(2000, 2000)
    world:setGravity(0, 40)

    -- callbacks
    world:setCallbacks(collide, touch, untouch, result)

    -- Add all the balls.
    --addball(balldefs[1], 50) -- Add 100 green.
    addball(balldefs[1], 5) -- Add 5 big.
    --addball(balldefs[3], 25) -- Add 50 pink.
 
    -- ground
    ground.b = love.physics.newBody( world, 0, 0, 0 )
    ground.s = love.physics.newRectangleShape( ground.b, 400, 580, 800, 12)
    ground.otype = "ground"
    ground.s:setData(ground)

    -- islands
    for i=1,5 do
			  addisland(math.random(0, 800), math.random(0, 400))
    end

    -- llama
    llama.b = love.physics.newBody( world, 420, 520, 0)
    llama.i = images.llama
    llama.otype = "llama"
    llama.looking = 1 -- llama is looking left
    llama.ox = llama.i:getWidth() / 2
    llama.oy = llama.i:getHeight() / 2
    llama.s = love.physics.newRectangleShape( llama.b, 0, 0, llama.i:getWidth(), llama.i:getHeight())
    llama.s:setData(llama)
    llama.b:setPosition(420, 520)
end

function love.update(dt)

    -- Update the world.
    world:update(dt)

    -- Check whether we need to reset some balls.
    -- When they move out of the screen, they
    -- respawn above the screen.
    for i,v in ipairs(balls) do
	    local x, y = v.b:getPosition()
		  if x > 850 or y > 650 then
			  v.b:setPosition(math.random(0, 800), -math.random(1200, 1500))
			  v.b:setLinearVelocity(0, 0)
		  end
    end    

    for i,v in ipairs(systems) do
      v:update(dt)
      if v:isFull() then  -- remove finished particlesystems
        table.remove(systems, i)
      end
    end

    -- input
    if love.keyboard.isDown("left") then
      flip_llama("left")
    end
    if love.keyboard.isDown("right") then
      flip_llama("right")
    end
    if love.keyboard.isDown("space") then
      print("space")
    end
end

function love.draw()
    -- background image
    love.graphics.draw(images.bg, 0, 0, 0, 
        love.graphics.getWidth() / images.bg:getWidth(),
        love.graphics.getHeight() / images.bg:getHeight(),
        0, 0)
  
    -- infos / stats
		love.graphics.print(points .. " Pts", 730, 30);
    -- draw the ground -- only for debugging
    --love.graphics.polygon("line", ground.s:getPoints())

    --draw islands
    for i,v in ipairs(islands) do
        love.graphics.draw(v.i, v.b:getX(), v.b:getY(), 0, 1, 1, v.r, v.r)
    end

    -- Draw all the balls.
    for i,v in ipairs(balls) do
        love.graphics.draw(v.i, v.b:getX(), v.b:getY(), v.b:getAngle(), 1, 1, v.ox, v.oy)
    end

    love.graphics.draw(llama.i, llama.b:getX(), llama.b:getY(), 0 , llama.looking, 1, llama.ox, llama.oy)

    for i,v in ipairs(systems) do
        love.graphics.draw(v, 0, 0)
    end
end

function addisland(x, y, r)
  local t = {}
  t.r = 25
	t.b = love.physics.newBody(world, x, y)
	t.s = love.physics.newCircleShape(t.b, t.r)
  t.otype = "island"
	t.i = images.island
  t.s:setData(t)
	table.insert(islands, t)
end


function addball(def, num)
    for i=1,num do
      local x, y = math.random(0, 800), -math.random(100, 1500)
      local t = {}
      t.b = love.physics.newBody(world, x, y)
      t.s = love.physics.newCircleShape(t.b, def.r)
      t.i = def.i
      t.otype = "object"
      t.ox = def.ox
      t.oy = def.oy
      t.b:setMassFromShapes()
      t.s:setData(t)
      table.insert(balls, t)
    end
end

function collide(a, b, coll)
  if a and b then
    if (a.otype == "ground") and (b.otype == "object") then
      explode_object(b.b)
    elseif (a.otype == "object") and (b.otype == "ground") then
      explode_object(a.b)
    elseif (a.otype == "object") and (b.otype == "llama") then
      a.b:setPosition( math.random(0, 800), -math.random(100, 1500))
      points = points + 1
    elseif (a.otype == "llama") and (b.otype == "object") then
      b.b:setPosition( math.random(0, 800), -math.random(100, 1500))
      points = points + 1
    end
  end
end

function touch(a, b, coll)
end
function untouch(a, b, coll)
end
function result(a, b, coll)
end

function explode_object(ob)
  explosion(ob:getX(), ob:getY())
  ob:setPosition( math.random(0, 800), -math.random(100, 1500))

  -- every destroyed object subtracts one point
  points = points - 1
end

function explosion(x, y)
	local p = love.graphics.newParticleSystem(images.part1, 1000)
	p:setEmissionRate(100)
	p:setSpeed(300, 400)
	p:setGravity(0)
	p:setSize(2, 1)
	p:setColor(255, 255, 255, 255, 58, 128, 255, 0)
	p:setPosition(x, y)
	p:setLifetime(0.5)
	p:setParticleLife(1)
	p:setDirection(0)
	p:setSpread(360)
	p:setTangentialAcceleration(1000)
	p:start()
 table.insert(systems, p)
end

function flip_llama(orientation)
  if (llama.looking == 1 and orientation == "right") then
    llama.looking = -1
  elseif (llama.looking == -1 and orientation == "left") then
    llama.looking = 1
  end
end
