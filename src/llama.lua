Llama = {}
Llama.__index = Llama

function Llama.create(w, x, y, img)
    local llama = {}
    setmetatable(llama, Llama)

    llama.b = love.physics.newBody( w, x, y, 0)
    llama.i = img
    llama.otype = "llama"
    llama.looking = 1 -- llama is looking left
    llama.y_null = nil
    llama.ox = llama.i:getWidth() / 2
    llama.oy = llama.i:getHeight() / 2
    llama.s = love.physics.newRectangleShape( llama.b, 0, 0, llama.i:getWidth(), llama.i:getHeight())
    llama.b:setLinearDamping(8)
    llama.b:setAllowSleeping(true)
    llama.speed = 55
    llama.b:setMass(0, 0, 15, 12)
    llama.s:setData(llama)
    llama.b:setPosition(x, y)

    print(llama.b:getMass())
    print(llama.b:getInertia())
    return llama
end

function Llama:draw()
    love.graphics.draw(self.i, self.b:getX(), self.b:getY(), 0 , self.looking, 1, self.ox, self.oy)
end

function Llama:update()
  -- stop the llama if it leaves the world , let it bounce back
  if (self.b:getX()-self.ox <= 5) then
    --vx, vy = self.b:getLinearVelocity()
    self.b:setX(5+self.ox)
    --self.b:setLinearVelocity(25, vy)
  elseif (self.b:getX()+self.ox >= love.graphics.getWidth()-5) then
    self.b:setX(love.graphics.getWidth()-5-self.ox)
    --self.b:applyImpulse(0, 0, 50, 0)
  end

  if (self.b:getY() == self.y_null) then
    vx, vy = self.b:getLinearVelocity()
    self.b:setLinearVelocity(vx, 0)
  end
end

function Llama:flip(ornt)
  if (self.looking == 1 and ornt == "right") then
    self.looking = -1
  elseif (self.looking == -1 and ornt == "left") then
    self.looking = 1
  end
end

function Llama:move_left()
  if (self.b:getX()-self.ox >= 5) then
    self.b:applyImpulse( -self.speed, 0, self.b:getX(), self.b:getY() )
  end
end

function Llama:move_right()
  if (self.b:getX()+self.ox <= love.graphics.getWidth()-5) then
    self.b:applyImpulse( self.speed, 0, self.b:getX(), self.b:getY() )
    --self.b:setLinearVelocity( 200, 0 )
  end
end

function Llama:move_up()
  if not self.y_null then
    self.y_null = self.b:getY()-5
  end
  if self.y_null <= self.b:getY() then --only allow jumping if standing on the ground
  --self.b:applyForce( 0, -1200, self.b:getX(), self.b:getY() )
    self.b:applyImpulse( 0, -480, self.b:getX(), self.b:getY() )
  end
end
