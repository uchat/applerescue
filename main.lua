display.setStatusBar(display.HiddenStatusBar)

local physics = require( "physics" )
physics.start()

local STATE = {wait=0, running=1, won=2, lost=3}

local state = STATE.wait
local doGround, doBackground, doApple, doDamageText

local function gameLost()
    state = STATE.lost
    doApple:removeSelf()
    local skull = display.newImage("images/skull.png")
    skull.x, skull.y = doApple.x, doApple.y
    transition.to(skull, {time=2000, y=skull.y - 200, alpha=0, onComplete=function(o)
        skull:removeSelf()
        skull = nil
    end})
    doDamageText.text = "You Lost!\n" .. doDamageText.text
end

local function gameWon()
    state = STATE.won
    doDamageText.text = "You Won!\n" .. doDamageText.text
end

local function setupScene()
    doBackground = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    doBackground.anchorX, doBackground.anchorY = 0, 0
    doBackground:setFillColor(177/255, 222/255, 255/255)
    doDamageText = display.newText("damage : 0%",
                    display.contentCenterX, 50, native.systemFontBold, 12 )
    doGround = display.newImage("images/ground.png")
    doGround.kind = "ground"
    doGround.x, doGround.y = display.contentCenterX, 480
    physics.addBody(doGround, "static", { density=1.0, friction=0.3, bounce=0.2 })
end

local function makeBlock(image, density, friction, bounce)
    local rect = display.newImage(image)
    rect.kind = "block"
    physics.addBody( rect, { density=density, friction=friction, bounce=bounce } )
    rect:addEventListener("tap", function(e)
        rect:removeSelf()
    end)
    return rect
end

local function setupBlock(blocks)
    for i=1,#blocks do
        local block = blocks[i]
        local blockObj = makeBlock("images/" .. block[1], block[2], block[3], block[4])
        blockObj.x, blockObj.y = block[5], block[6]
    end
end

local function setupApple(apple)
    local appleShape = { -5.5,10, 0,11, 5.5,10, 10,1, 7,-6, 0,-7.5, -7,-6, -10,1 }
    doApple = display.newImage("images/apple.png")
    doApple.x, doApple.y = apple.x, apple.y
    doApple.damage = 0
    doApple.maxDamage = apple.maxDamage
    physics.addBody(doApple, { density=1.0, friction=0.3, bounce=0.2, shape=appleShape })
    doApple:addEventListener("postCollision", function(event)
        if event.force < 0.5 or state ~= STATE.running then return end
        doApple.damage = doApple.damage + event.force
        local percent = math.floor(doApple.damage / doApple.maxDamage * 100)
        doDamageText.text = "damage : " .. percent .. "%"
        if percent > 100 then
            gameLost()
            return
        end
        if event.other.kind == "ground" then
            gameWon()
        end
    end)
end


local function setupLevel(level)
    setupScene()
    setupBlock(level.blocks)
    setupApple(level.apple)    
end

-- main --

local level1 = {
    blocks = {
        {"block12x1.png", 1, 0.8, 0.1, 195, 295},    
        {"wood4x4.png", 0.5, 0.5, 0.3, 150, 320},
        {"wood4x4.png", 0.5, 0.5, 0.3, 225, 320},
        {"foam4x4.png", 0.2, 0.5, 0.7, 170, 360},
        {"foam4x4.png", 0.2, 0.5, 0.7, 210, 360},
        {"wood4x4.png", 0.5, 0.5, 0.3, 190, 400},
        {"wood4x4.png", 0.5, 0.5, 0.3, 190, 440},
        
    },
    apple = {
        maxDamage = 5,
        x = 190,
        y = 280
    }

}

setupLevel(level1)
state = STATE.running
