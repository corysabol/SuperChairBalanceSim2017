gfx = love.graphics
kb = love.keyboard
phys = love.physics
audio = love.audio

require 'chair'

function love.load()

  hasRepeat = false

  -- do some set up
  if love.keyboard.hasKeyRepeat() == true then
    hasRepeat = true
    kb.setKeyRepeat( false )
  end

  gfx.setBackgroundColor(100, 50, 100)
  --song = audio.newSource("assets/DNBBB.wav")

  local sx = 1
  local sy = 1
  local state = "play"
  local ground = {}
  local ground.x = 650
  local ground.y = 500 
  local ground.w = 800
  local ground.h = 50
  phys.setMeter(64)
  world = phys.newWorld(0, 9.18*64, true)
  world:setCallbacks(beginContact, endContact)
  ground.body = phys.newBody(world, ground.x / 2, ground.y, "static")
  ground.shape = phys.newRectangleShape(ground.w / 2, ground.h)
  ground.fixture = phys.newFixture(ground.body, ground.shape)

  idleSprite = gfx.newImage("assets/idle.png")
  idleSprite:setFilter("nearest")
  leftSprite = gfx.newImage("assets/leanleft.png")
  leftSprite:setFilter("nearest")
  rightSprite = gfx.newImage("assets/leanright.png")
  rightSprite:setFilter("nearest")
  chairSprite = idleSprite 
  chairSprite:setFilter("nearest")

  chair = chair:init(650/2, ground.h-18/2, 8, 18, chairSprite, world, 4, 4)  

  keys = {
    jump = false,
    left = false,
    right = false
  }

  -- set up a particle system
  local bloodPart = gfx.newImage("assets/bloodParticle.png")
  bloodPart:setFilter("nearest")
  parSys = gfx.newParticleSystem(bloodPart, 25)
  parSys:setParticleLifetime(2, 10) -- live at least 2 seconds at most 5 seconds
  parSys:setEmissionRate(10)
  parSys:setSizeVariation(0.25)
  parSys:setLinearAcceleration(-20, 20, 20, 5)
  parSys:setColors(255,255,255,255,255,255,255,255) -- fade to transparent
  parSys:setSpeed(-100, 100)

  love.window.setMode(650, 650, { vsync=true })
end

function love.update(dt)
  -- Play the song
  --song:play()
  -- Set the world into motion
  world:update(dt)
  parSys:update(dt)
  parSys:setPosition(chair.body:getX(), chair.body:getY())

  if keys.right == true then
    chair.body:applyAngularImpulse(1500)
    chair.sprite = rightSprite
  elseif keys.left == true then
    chair.body:applyAngularImpulse(-1500)
    chair.sprite = leftSprite
  end

  if keys.space == true and chair.canJump == true and chair.onGround then
    chair.body:applyLinearImpulse(0, -1500)
    chair.sprite = leftSprite
    chair.canJump = false
  end

  if keys.space == false and chair.onGround == true then
    chair.canJump = true
  end
      
  chair:update( dt )
  score( chair, dt )
end

function love.draw()
  gfx.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

  gfx.print("Press r to restart", 15, 25)

  if state == "gameOver" then
    gfx.print("Game over, press ESC to quit, chump!", 15, 45)
  end
  
  gfx.print("score: "..math.floor(chair.score * 10), 15, 35)
  gfx.print("mult: "..chair.scoreMult.."x", 15, 65)
  if chair.onGround then
    gfx.print("on the ground son", 15, 75)
  else
    gfx.print("not on the ground son", 15, 75)
  end
  
  if chair.canJump then
    gfx.print("can jump mang", 15, 85)
  else
    gfx.print("can't jump mang", 15, 85)
  end

  if hasRepeat == true then
    gfx.print("keyboard has repeat")
  else
    gfx.print("keyboars doesn't have repeat")
  end

  chair.draw()

  -- draw the particle system
  local x, y = parSys:getPosition()
  gfx.draw(parSys, x, y) 
end

function score( c, dt )
  -- we score based on the chairs angle
  -- if the chair is greater than 5 deg and less than 85 we can score
  if math.floor(c.angle) >= 5 and math.floor(c.angle) <= 85 then
    c.score = c.score + ((c.score * c.scoreMult) * dt) * dt + 1
    state = "play"
    c.balancing = true
  -- if the angle is greater than 95 and less then 175 we can also score
  elseif math.floor(c.angle) >= 95 and math.floor(c.angle) <= 175 then
    c.score = c.score + ((c.score * c.scoreMult) * dt) * dt + 1
    state = "play"
    c.balancing = true
  elseif math.floor(c.angle) >= 175 and math.floor(c.angle) <= 360 and c.onGround == false then
    c.score = c.score + ((c.score * c.scoreMult) * dt) * dt + 1
    state = "play"
  elseif math.floor(c.angle) > 85 and math.floor(c.angle) < 95 and c.onGround then
    state = "gameOver"
    c.balancing = false
  end

  -- set the score multiplier
  -- we use the raw angle of the chair to check number of flips.
  -- this angle should be set to the normalized angle on land
  local flips = math.abs(math.floor(math.floor(c.rawAngle) / 360))
  if flips == 0 then
    c.scoreMult = 1
  elseif flips == 1 then
    c.scoreMult = c.scoreMult + 2 
  else
    c.scoreMult = c.scoreMult + flips
  end
end

function reset() 
  --song:stop()
  love.load()
end

-- collision callbacks
function beginContact(a, b, col)
  chair.onGround = true

  if chair.hadFirstContact == false then
    chair.hadFirstConatact = true
  end
end

function endContact(a, b, col)
  if chair.onGround == true then
    chair.onGround = false
  end
end

function love.keypressed( key )
  if key == 'space' then
    keys.space = true
  elseif key == 'a' then
    keys.left = true
  elseif key == 'd' then
    keys.right = true
  end

  if key == 'k' then
    chair = nil
  end

  if key == "escape" then
    love.event.quit()
  end
  if key == 'r' then
    reset()
  end
end

function love.keyreleased( key )
  if key == 'space' then
    keys.space = false
  elseif key == 'a' then
    keys.left = false
  elseif key == 'd' then
    keys.right = false
  end
end
