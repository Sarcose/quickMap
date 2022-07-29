local st1 = 'Welcome to quickMap! Convert an image into a lua table of rectangles for super simple mapping.\n'
local st2 = 'Drag and drop an image onto the window (BMP or PNG only)\n'
local st3 = 'Press +/- to change pixel size:\n'
local st4 = '(object width and height will have a minimum of this value)\n'
local st5 = 'Press F to type output filename (leave blank for <originalname>.lua):\n'
local st6 = 'Press C to choose whether colors separate output rects:\n'
local st7 = 'Press Tab at any time to change the text color of the UX\n'
local st8 = 'Press H at any time to hide this interface\n'

local interface = {
    x = 10,y=10,font=lg.newFont('assets/font/LanaPixel.ttf',20),color = {1,1,1},colorind = 1,
    start = {
        text = st1..st2..st3..st4..st5..st6..st7..st8,
        draw = function(self)
            local font = self.font
            local fspace = font:getHeight('W')
            local _ = ''
            if doTextInput then _ = '_'end
            lg.setFont(font)
            lg.setColor(self.color)
            lg.print(self[self.state].text,self.x,self.y)
            lg.print(tostring(PIXELSIZE),font:getWidth(st3)+15,fspace*2+10)
            lg.print(tostring('<'..FILENAME.._..'>'..'.lua'),font:getWidth(st5)+15,fspace*4+10)
            lg.print(tostring(BYCOLOR),font:getWidth(st6)+15,fspace*5+10)
        end
    },
    error = {
        timer = 5,
        timerdefault = 5,
        t1 = 'Invalid filetype!',
        errorItem = '',
        t2 = 'Imagetypes other than png or bmp will not work well with this\nmethod and thus are not supported. Sorry!\nPress any key or wait to continue...',
        draw = function(self)
            local font = self.font
            local fspace = font:getHeight('W')
            lg.setColor(self.color)
            lg.print(self[self.state].t1,self.x+10,self.y)
            lg.print('*.'..self[self.state].errorItem,self.x+10,self.y+fspace)
            lg.print(self[self.state].t2,self.x+10,self.y+fspace*2)
        end
    },
    processing = {
        t1 = 'Processing image...',
        draw = function(self)
            local font = self.font
            local fspace = font:getHeight('W')
            lg.setColor(self.color)
            lg.print(self[self.state].t1,self.x+10,self.y)
            lg.print('Pixelsize: '..tostring(PIXELSIZE),self.x+10,self.y+fspace)
            lg.printf(currentProcessingState,self.x+10,self.y+fspace*3,lg.getWidth())
        end
    },
    mapDone = {
        text = 'Arrows: move map (shift: faster)\n+/-: Zoom\nH: hide interface\nESC: restart',
        draw = function(self)
            local font = self.font
            local fspace = font:getHeight('W')
            lg.setColor(self.color)
            lg.print(self[self.state].text,lg.getWidth()/2-font:getWidth(self[self.state].text),lg.getHeight()/2)
        end
    }
}

UXColors = {
    {1,1,1},
    {1,0,0},
    {0,1,0},
    {0,0,1},
    {0,0,0},
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
            h = {'key:h'},
            up = {'key:up'},
            down = {'key:down'},
            left = {'key:left'},
            right = {'key:right'},
            shift = {'key:lshift','key:rshift'},
            colortoggle = {'key:tab'}
        },
        pairs = {
        },
        joystick = love.joystick.getJoysticks()[1],
        deadzone = .33,
    }
    self.state = 'start'
end
function interface:changeState(state,t)
    self[self.state].timer = self[self.state].timerdefault
    self.state = state
    self[self.state].errorItem = t
end

function interface:update(dt)
    self.controller:update(dt)
    if self[self.state].timer then self[self.state].timer = self[self.state].timer - dt 
        if self[self.state].timer <= 0 then self:changeState('start') end
    end
    self:parseControls()
end

function interface:parseControls()
    local c = self.controller
    if c:pressed('h') then self.hide = boolSwitch(self.hide) end
    if c:pressed('colortoggle') then 
        self.colorind = self.colorind + 1
        if self.colorind > #UXColors then self.colorind = 1 end
        self.color = UXColors[self.colorind]
    end
    if self.state == 'start' then
        if c:pressed('plus') then PIXELSIZE = PIXELSIZE + 1
        elseif c:pressed('minus') then PIXELSIZE = PIXELSIZE - 1
        end
        if c:pressed('f') then doTextInput = true end
        if c:pressed('enter') then doTextInput = false end
        if c:pressed('escape') and doTextInput then FILENAME = '' doTextInput = false end
        if c:pressed('c') then BYCOLOR = boolSwitch(BYCOLOR) end
    elseif self.state == 'mapDone' then
        local speed = CAMERASPEED
        if c:down('shift') then speed = speed * 2 end
        if c:down('up') then CAMERAY = CAMERAY - speed
        elseif c:down('down') then CAMERAY = CAMERAY + speed 
        end
        if c:down('left') then CAMERAX = CAMERAX - speed
        elseif c:down('right') then CAMERAX = CAMERAX + speed
        end
        if c:down('plus') then CAMERASCALE = CAMERASCALE + SCALERATE
        elseif c:down('minus') then CAMERASCALE = CAMERASCALE - SCALERATE
        end
    end
    if c:pressed('escape') then _G.displayMap = nil self.state = 'start' end
end

function interface:draw()
    if not self.hide then 
        if self[self.state].draw then self[self.state].draw(self) end
    end
end

return interface