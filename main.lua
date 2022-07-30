lg = love.graphics
local utf8 = require("utf8")
local baton = require 'lib.baton'
local interface = require 'src.interface'
local collisionMask = require 'src.collisionMask'
require 'src.utility'
PIXELSIZE = 4
FILENAME = ''
OUTPUTNAME = ''
BYCOLOR = true
doTextInput = false
CAMERAX,CAMERAY,CAMERASCALE = 0,0,5
CAMERASPEED = 10
SCALERATE = 0.1
DRAWSTYLE = 'line'
currentProcessingState = ''
displayMap = {}

function love.load()
    interface:load(baton)
    _G.displayCanvas = lg.newCanvas(lg.getWidth(),lg.getHeight())
    
end

function love.update(dt)
    interface:update(dt)
    if collisionMask.started then collisionMask:update(dt) end
end
BGColors = {
    {0,0,0},
    {0.7,0.7,0.7},
    {1,1,1},
    {0.7,0,0},
    {0,0.7,0},
    {0,0,0.7},
}
function love.draw()
    lg.clear(BGColors[interface.bgind])
    drawMap()
    interface:draw()
end

function love.textinput(t)
    if doTextInput then
        OUTPUTNAME = OUTPUTNAME..t
    elseif interface.state == 'error' then
        interface:changeState('start')
    end
end
function love.keypressed(key)
    if key == "backspace" then  --copied right from the tutorial
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(OUTPUTNAME, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            OUTPUTNAME = string.sub(OUTPUTNAME, 1, byteoffset - 1)
        end
    end
end

local validTypes = {png = true,bmp = true,}
function love.filedropped(file)
	file:open("r")
    FILENAME = file:getFilename()
    FILENAME = get_file_name(FILENAME)
    FILENAME = removeBMPExtensions(FILENAME)
    FILENAME = removePNGExtensions(FILENAME)
    local t = file:getExtension()
    if validTypes[t] then
        interface:changeState('processing')
        local image = love.graphics.newImage(file)
        collisionMask:loadMask(image,interface)
    else
        interface:changeState('error',t)
    end
end

function drawMap()
    lg.setColor(1,1,1,1)
    if type(_G.displayMap) == 'table' then
        lg.setCanvas(_G.displayCanvas)
        lg.clear(BGColors[interface.bgind])
        for rgbname,color in pairs(_G.displayMap) do
            for i,v in ipairs(color) do
                lg.setColor(v.r,v.g,v.b,1)
                lg.rectangle(DRAWSTYLE,v.x,v.y,v.w,v.h)
            end
        end
        lg.setCanvas()
        lg.setColor(1,1,1,1)
        lg.draw(_G.displayCanvas,CAMERAX,CAMERAY,0,CAMERASCALE)
    end
end

_G.WRITESUCCESS = 'NA'
function writeMap(map)
    if OUTPUTNAME == '' then OUTPUTNAME = FILENAME..'.lua'
    else OUTPUTNAME = OUTPUTNAME..'.lua' print('outputname')
    end
    _G.WRITESUCCESS,_G.WRITEMESSAGE = love.filesystem.write(OUTPUTNAME, "local map = " .. TableToString(map,0).."return map")
end

function get_file_name(path)   
    local start, finish = path:find('[%w%s!-={-|]+[_%.].+')   
    return path:sub(start,#path) 
end

function removePNGExtensions(s)
    return s:gsub("%.png", "")
end
function removeBMPExtensions(s)
    return s:gsub("%.bmp", "")
end


