-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local actor = {}

local touchedPoint = nil

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--physics.setGravity( 0, 20 )

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local screenMax = math.max(display.contentHeight, display.contentWidth)
local screenMin = math.min(display.contentHeight, display.contentWidth)

local onRuntimeTouch

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local Map = { width = 50, height = 600, actorX = 25, actorY = 30, actorRadius = 5 }
Map[1] = { y = 10, x = 25, width = 48, height = 4 }
Map[2] = { y = 25, x = 5, width = 10, height = 3 }
Map[3] = { y = 45, x = 45, width = 10, height = 3 }
Map[4] = { y = 65, x = 5, width = 10, height = 3 }
Map[5] = { y = 95, x = 25, width = 15, height = 3 }
Map[6] = { y = 125, x = 45, width = 15, height = 3 }

-- this determines how much x and y in Map are scaled
local scaleMap
local xOffset



-- utility functions
function distance(x1, y1, x2, y2)
	return math.sqrt((x1-x2)^2+(y1-y2)^2)
end

local function getAngleDegrees(x1, y1, x2, y2)
	local PI = 3.14159265358
	local deltaY = y2 - y1
	local deltaX = x2 - x1
	return 360 - (((math.atan2(deltaY, deltaX) * 180)/ PI)+360)%360
end

-- end of utility functions

local function print_obstacle(obstacle)
	print ("obstacle x=", obstacle.x, " y=", obstacle.y, " width=", obstacle.width, " height=", obstacle.height)
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	local newGroup = display.newGroup()

	-- create a grey rectangle as the backdrop
	--local background = display.newRect( 0, 0, screenMax, screenMax )
	--background.anchorX = 0
	--background.anchorY = 0
	--background:setFillColor( .5 )
	
	local background = display.newImage( "backgroundTest.jpg", true )
	background.x = display.contentWidth / 2
	background.y = display.contentHeight / 2
	
	-- make a crate (off-screen), position it, and rotate slightly
	--local crate = display.newImageRect( "crate.png", 90, 90 )
	--local crate = display.newRect(0, 0, screenMax / 10, screenMax / 10)
	--crate.x, crate.y = 160, -100
	--crate.rotation = 15
	
	-- add physics to the crate
	--physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )
	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "grass.png", screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	grass.x, grass.y = 0, display.contentHeight
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( grass)
	--group:insert( crate )
	
	
	-- this determines how much x and y in Map are scaled
	scaleMap = (screenMin / Map.width) * 0.9
	xOffset = display.contentWidth * 0.05
	
	local left = display.newRect(0, 0, 1, display.contentHeight )
	left:setFillColor(0/255)
	left.x, left.y = xOffset, display.contentHeight/2
	physics.addBody( left, "static", { friction=100, bounce=0.1 } )
	
	local right = display.newRect(0, 0, 1, display.contentHeight )
	right:setFillColor(0/255)
	right.x, right.y = display.contentWidth - xOffset, display.contentHeight/2
	physics.addBody( right, "static", { friction=100, bounce=0.1 } )

	
	for i = 1, #Map do
		local object = display.newRect(0, 0, Map[i].width * scaleMap, Map[i].height * scaleMap)
		object.x, object.y = Map[i].x * scaleMap + xOffset, screenH - Map[i].y * scaleMap
		newGroup:insert(object)
		print_obstacle(object)
		
		physics.addBody( object, "static", { friction=100, bounce = 0.0 } )
		
		transition.to(object, { time=20000, y = object.y+ (Map.width * scaleMap) } )
	end

	actor = display.newCircle(0, 0, Map.actorRadius * scaleMap)
	--actor = display.newRect(0, 0, Map.actorRadius * scaleMap * 2, Map.actorRadius * scaleMap * 2)
	actor.x = Map.actorX * scaleMap + xOffset
	actor.y = screenH - Map.actorY * scaleMap	
	
	--physics.addBody( actor, { density=1.0, friction=0.3, bounce=0.3 } )
	physics.addBody( actor, { density=1.0, friction=100, bounce=0.0 } )
	actor.isFixedRotation  = true
	
	print("screenH=", screenH, " screenW=", screenW)
	print("scaleMap=", scaleMap)
	
	group:insert(actor)
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	Runtime:addEventListener( "touch", onRuntimeTouch )		
	
	physics.start()	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )	
	local group = self.view
	
	Runtime:removeEventListener( "touch", onRuntimeTouch )
		
	physics.stop()	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end


-- functions that were pre-declared

onRuntimeTouch = function ( event )
	if event.phase == "canceled" or event.phase == "ended"
	then
		if touchedPoint then
			print ("event ended, actorx is ", actor.x, " actory is ", actor.y)
			
			local distance = distance(touchedPoint.x, touchedPoint.y, event.x, event.y)
			
			local degrees = getAngleDegrees(touchedPoint.x, touchedPoint.y, event.x, event.y)
			-- from: http://stackoverflow.com/questions/11343097/corona-sdk-how-to-make-object-move-forward
			local angle = math.rad(degrees)  -- we need angle in radians
			local xComp = math.cos(angle)  -- the x component
			local yComp = -math.sin(angle)  -- the y component is negative because 
					--  "up" the screen is negative

			local forceMag = 0.5 -- change this value to apply more or less force
			-- now apply the force
			actor:applyLinearImpulse(forceMag*xComp * distance / 2, forceMag*yComp * distance / 2, actor.x, actor.y)
			
			print ("degrees=", degrees, " angle=", angle, " applied: x=", forceMag*xComp / 2, " y = ", forceMag*yComp / 2)
		end
		touchedPoint = nil
	elseif event.phase == "began"
	then
		touchedPoint = {}
		touchedPoint.x, touchedPoint.y = event.x, event.y
		
		print ("event began")
	end
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene