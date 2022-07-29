local st1 = 'Welcome to quickMap! Convert an image into a lua table of rectangles for super simple mapping.\n'
local st2 = 'Drag and drop an image onto the window (BMP or PNG only)\n'
local st3 = 'Press +/- to change pixel size:\n'
local st4 = 'Press F to type output filename (leave blank for <originalname>.lua):\n'
local st5 = 'Press C to choose whether colors separate output rects:\n'

local interface = {
    x = 10,y=10,font=lg.newFont('assets/font/LanaPixel.ttf',20),
    start = {
        text = st1..st2..st3..st4..st5,
        draw = function(self)
            local font = self.font
            local fspace = font:getHeight('W')
            local _ = ''
            if doTextInput then _ = '_'end
            lg.setFont(font)
            lg.setColor(1,1,1,1)
            lg.print(self[self.state].text,self.x,self.y)
            lg.print(tostring(PIXELSIZE),font:getWidth(st3)+15,fspace*2+10)
            lg.print(tostring('<'..FILENAME.._..'>'..'.lua'),font:getWidth(st4)+15,fspace*3+10)
            lg.print(tostring(BYCOLOR),font:getWidth(st5)+15,fspace*4+10)
        end
    }    
}


function interface:load(baton)
    self.controller = baton.new {
        controls = {
            plus = {'key:+','key:='},
            minus = {'key:-'},
            f = {'key:f'},
            enter = {'key:return'},
            c = {'key:c'},
            escape = {'key:escape'},
        },
        pairs = {
        },
        joystick = love.joystick.getJoysticks()[1],
        deadzone = .33,
    }
    self.state = 'start'
end
function interface:changeState(state)
    self.state = state
end

function interface:update(dt)
    self.controller:update(dt)
    self:parseControls()

end

function interface:parseControls()
    local c = self.controller
    if c:pressed('plus') then PIXELSIZE = PIXELSIZE + 1
    elseif c:pressed('minus') then PIXELSIZE = PIXELSIZE - 1
    end
    if c:pressed('f') then doTextInput = true end
    if c:pressed('enter') then doTextInput = false end
    if c:pressed('escape') and doTextInput then FILENAME = '' doTextInput = false end
    if c:pressed('c') then BYCOLOR = boolSwitch(BYCOLOR) end
end

function interface:draw()
    if self[self.state].draw then self[self.state].draw(self) end
end

return interface