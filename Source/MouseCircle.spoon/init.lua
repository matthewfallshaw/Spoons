--- === MouseCircle ===
---
--- Draws a circle around the mouse pointer when a hotkey is pressed
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/MouseCircle.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/MouseCircle.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "MouseCircle"
obj.version = "1.0"
obj.author = "Chris Jones <cmsj@tenshu.net>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.circle = nil
obj.timer = nil
obj.hotkey = nil

obj.dia = 80

--- MouseCircle.color
--- Variable
--- An `hs.drawing.color` table defining the colour of the circle. Defaults to red.
obj.color = nil

--- MouseCircle:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for MouseCircle
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * show - This will cause the mouse circle to be drawn
function obj:bindHotkeys(mapping)
    if (self.hotkey) then
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
    local circle = self.circle
    local timer = self.timer
    local dia = obj.dia

    if circle then
        circle:hide(0.5)
        if timer then
            timer:stop()
        end
    end

    mousepoint = hs.mouse.absolutePosition()

    local color = nil
    if (self.color) then
        color = self.color
    else
        color = {["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1}
    end
    circle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-dia/2, mousepoint.y-dia/2, dia, dia))
    circle:setStrokeColor(color)
    circle:setFill(false)
    circle:setStrokeWidth(5)
    circle:bringToFront(true)

    self.circle = circle

    self.pulsetimer = hs.timer.doEvery(0.4, function()
        if self.circle then
            self.circle:show(0.1)
            hs.timer.doAfter(0.15, function()
                if self.circle then self.circle:hide(0.1) end
            end)
        end
    end)

    self.timer = hs.timer.doAfter(3, function()
        if self.circle then self.circle:hide(0.1) end
        if self.pulsetimer then self.pulsetimer:stop() end
        hs.timer.doAfter(0.15, function()
            if self.circle then
                self.circle:delete()
                self.circle = nil
            end
            if self.pulsetimer then self.pulsetimer = nil end
            if self.timer then self.timer = nil end
        end)
    end)

    return self
end

return obj
