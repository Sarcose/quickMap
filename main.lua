lg = love.graphics

local baton = require 'lib.baton'
local interface = require 'src.interface'
local collisionMask = require 'src.collisionMask'
PIXELSIZE = 4
FILENAME = ''
BYCOLOR = true
doTextInput = false
CAMERAX,CAMERAY,CAMERASCALE = 0,0,5
CAMERASPEED = 10
SCALERATE = 0.3
DRAWSTYLE = 'line'
currentProcessingState = ''
displayMap = {}

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function deepcopy(orig,src)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key,src)] = deepcopy(orig_value,src)
        end
        setmetatable(copy, deepcopy(getmetatable(orig),src))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function tablePrint(t, name, tab, exclude, limit)
	local stop = false
	if limit then if limit == 1 then stop = true else limit = limit - 1 end end
	name = name or "table"
	tab = tab or ""
	print(tostring(tab).."  "..tostring(name).."= {")
	for i,v in pairs(t) do
		if i ~= exclude then
			if (type(v) == "table") then
				if not stop then tablePrint(t[i], i, tostring(tab).."  ",exclude,limit) 
					else print(tostring(tab).."    "..tostring(i).."= "..tostring(v))
				end

			else
			print(tostring(tab).."    "..tostring(i).."= "..tostring(v))
			end
		end
	end
	print(tostring(tab).."    ".."}")
end

function boolSwitch(bool)
    if bool then return false else return true end
end

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
    drawMap()
    interface:draw()
end

function love.textinput(t)
    if doTextInput then
        FILENAME = FILENAME..t
    elseif interface.state == 'error' then
        interface:changeState('start')
    end
end
local validTypes = {png = true,bmp = true,}
function love.filedropped(file)
	file:open("r")
    local name = file:getFilename()
    local t = file:getExtension()
    if validTypes[t] then
        interface:changeState('processing')
        local image = love.graphics.newImage(file)
        collisionMask:loadMask(image,interface)
    else
        interface:changeState('error',t)
    end

	--local data = file:read()
	--print("Content of " .. file:getFilename() .. ' is')
	--print(data)
	--print("End of file")
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
function getFileType(filename)

end
