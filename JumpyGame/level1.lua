-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local screenMax = math.max(display.contentHeight, display.contentWidth)
local screenMin = math.min(display.contentHeight, display.contentWidth)

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local Map = { width = 50, height = 600}
Map[1] = { y = 10, x = 25, width = 48, height = 4 }
Map[2] = { y = 15, x = 5, width = 3, height = 3 }

-- this determines how much x and y in Map are scaled
local scaleMapX
local scaleMapY 

local function print_obstacle(obstacle)
	print ("obstacle x=", obstacle.x, " y=", obstacle.y, " width=", obstacle.width, " height=", obstacle.height)
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenMax, screenMax )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( .5 )
	
	-- make a crate (off-screen), position it, and rotate slightly
	--local crate = display.newImageRect( "crate.png", 90, 90 )
	local crate = display.newRect(0, 0, screenMax / 10, screenMax / 10)
	crate.x, crate.y = 160, -100
	crate.rotation = 15
	
	-- add physics to the crate
	physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )
	
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
	group:insert( crate )
	
	
	-- this determines how much x and y in Map are scaled
	local scaleMapX = screenMin / Map.width
	local scaleMapY = screenMax / Map.height

	
	local object1 = display.newRect(0, 0, Map[1].width * scaleMapX, Map[1].height * scaleMapY)
	object1.x, object1.y = Map[1].x * scaleMapX, screenH - Map[1].y * scaleMapY
	
	local object2 = display.newRect(0, 0, Map[2].width * scaleMapX, Map[2].height * scaleMapY)
	object2.x, object2.y = Map[2].x * scaleMapX, screenH - Map[2].y * scaleMapY
	
	print("screenH=", screenH, " screenW=", screenW)
	print("scaleMapX=", scaleMapX, " scaleMapY=", scaleMapY)
	
	group:insert(object1)
	group:insert(object2)
	
	print_obstacle(object1)
	print_obstacle(object2)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	physics.start()
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
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