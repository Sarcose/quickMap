lg = love.graphics

local baton = require 'lib.baton'
local flux = require 'lib.flux'
local interface = require 'src.interface'
PIXELSIZE = 4
FILENAME = ''
BYCOLOR = true
doTextInput = false

function boolSwitch(bool)
    if bool then return false else return true end
end

function love.load()
    interface:load(baton)
end

function love.update(dt)
    flux.update(dt)
    interface:update(dt)
end

function love.draw()
    interface:draw()

end

function love.textinput(t)
    if doTextInput then
        FILENAME = FILENAME..t
    end
end

function love.filedropped(file)
	file:open("r")
	local data = file:read()
	print("Content of " .. file:getFilename() .. ' is')
	print(data)
	print("End of file")
end
