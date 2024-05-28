--- === MouseCircle ===
---
--- Draws a circle around the mouse pointer when a hotkey is pressed
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/MouseCircle.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/MouseCircle.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "MouseCircle"
obj.version = "1.1"  -- Updated version number
obj.author = "Chris Jones <cmsj@tenshu.net>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.circle = nil
obj.timer = nil
obj.hotkey = nil

obj.dia = 80  -- Diameter of the smallest circle

--- MouseCircle.colour
--- Variable
--- An hs.drawing.colour table defining the colour of the circle. Defaults to red.
obj.colour = {["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1}

--- MouseCircle:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for MouseCircle
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * show - This will cause the mouse circle to be drawn
function obj:bindHotkeys(mapping)
    if type(mapping) ~= "table" or not mapping["show"] then
        error("Invalid mapping")
    end

    if self.hotkey then
        self.hotkey:delete()
    end

    local showMods = mapping["show"][1]
    local showKey = mapping["show"][2]
    self.hotkey = hs.hotkey.bind(showMods, showKey, function() self:show() end)

    return self
end

--- MouseCircle:show()
--- Method
--- Draws a circle around the mouse
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:show()
    -- Stop and delete existing circle and timer if they exist
    if self.circle then
        self.circle:delete()
        self.circle = nil
    end
    if self.timer then
        self.timer:stop()
        self.timer = nil
    end

    -- Get the current mouse position
    local mousepoint = hs.mouse.absolutePosition()

    -- Define the initial diameter and step for reducing the size
    local scale = 10
    local initialDia = self.dia * scale

    -- Define the stroke width
    local strokeWidth = 5
    local halfStroke = strokeWidth / 2

    -- Adjust canvas size to account for stroke width
    self.circle = hs.canvas.new({
        x = mousepoint.x - initialDia / 2 - halfStroke,
        y = mousepoint.y - initialDia / 2 - halfStroke,
        h = initialDia + strokeWidth,
        w = initialDia + strokeWidth
    })
    self.circle:appendElements({
        type = "circle",
        action = "stroke",
        strokeWidth = strokeWidth,
        strokeColor = obj.colour,
        padding = halfStroke
    }):level(hs.canvas.windowLevels.cursor)

    -- Additional properties for the sinusoidal animation
    local animationDuration = 2  -- Total duration of the animation in seconds
    local startTime = hs.timer.secondsSinceEpoch()

    local function updateCircleSize()
        local currentTime = hs.timer.secondsSinceEpoch()
        local elapsedTime = currentTime - startTime

        if elapsedTime < animationDuration then
            local sineValue = math.cos(math.pi * elapsedTime / animationDuration)
            local dia = self.dia + sineValue * (self.dia * (scale - 1)) -- oscillate between dia and 1.5 * dia

            -- Update frame and show immediately
            self.circle:frame({
                x = mousepoint.x - dia / 2 - halfStroke,
                y = mousepoint.y - dia / 2 - halfStroke,
                h = dia + strokeWidth,
                w = dia + strokeWidth
            })
            self.circle[1].frame = { x = halfStroke, y = halfStroke, h = dia, w = dia }
            self.circle:show()
        else
            self.timer:stop()
            hs.timer.doAfter(0.1, function()
                self.circle:delete()
                self.circle = nil
            end)
        end
    end

    -- Adjust the timer interval for smoother animation
    self.timer = hs.timer.doEvery(0.05, updateCircleSize)

    return self
end

return obj
