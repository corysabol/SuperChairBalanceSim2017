--[[
-- The chair should probably just use a rigidbody to minimize the amout of
-- pseudo physics I will need to code and this will be easier to mimic balancing
-- a chair on it's legs
--]]

gfx = love.graphics
phys = love.physics

require 'inherit'

chair = inherit( nil ) -- turn the chair into a "class" 

function chair:init(x, y, w, h, sprite, world, scaleX, scaleY)
  chair.hadFirstContact = false
  chair.angle = 0
  chair.rawAngle = 0
  chair.onGround = true 
  chair.canJump = true
  chair.score = 0
  chair.scoreMult = 1
  chair.flips = 0
  chair.fallen = false
  chair.balancing = false
  chair.x = x
  chair.y = y
  chair.sx = scaleX
  chair.sy = scaleY
  chair.sprite = sprite
  chair.w = sprite:getWidth()
  chair.h = sprite:getHeight()
  chair.body = phys.newBody(world, chair.x, chair.y, "dynamic")
  chair.shape = phys.newRectangleShape((chair.w * chair.sx) - 10, chair.h * chair.sx)
  chair.fixture = phys.newFixture(chair.body, chair.shape, 1) 
  return chair
end

function chair:update(dt)
  chair.angle = (math.deg(chair.body:getAngle()) + 90) % 360
  chair.rawAngle = math.deg(chair.body:getAngle()) + 90
end

function chair:rotate(radians)
  chair.angle = radians
end

function chair:draw() 
  --gfx.polygon("line", chair.body:getWorldPoints(chair.shape:getPoints()))
  gfx.draw(chair.sprite, chair.body:getX(),
          chair.body:getY(), chair.body:getAngle(), chair.sx, chair.sy,
          chair.w / 2, chair.h / 2)
end
