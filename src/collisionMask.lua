local mask = {}




function mask:loadMask(image,interface)--,world,parentMap,layer,layertoaddto)
	self.started = true
	self.interface = interface
	local w,h = image:getPixelDimensions()
	local mapCanvas = love.graphics.newCanvas(w,h)
	mapCanvas:renderTo(
		function()lg.draw(image)end
	)
	local mapImage = mapCanvas:newImageData()
	self.w = mapImage:getWidth(mapImage)
	self.h = mapImage:getHeight(mapImage)
	self.s = PIXELSIZE
	self.w=self.w-1
	self.h=self.h-1
	self.mapImage = mapImage
	
	self.state = 'buildBase'
	currentProcessingState = currentProcessingState..'building base table...'
end

function mask:update(dt)
	self[self.state](self,dt)
end

function mask:buildBase(dt)
	self.baseTable = {}
	local w = self.w
	local h = self.h
	local s = self.s
	local mapImage = self.mapImage
	local rgbstring = "items"
	for my=0, h, s do
		for mx=0 , w, s do
			local r, g, b = mapImage:getPixel(mx, my)
			if r+g+b ~= 0 then
				local item = {
					x=mx,
					y=my,
					w=s,
					h=s,
					r=r,
					g=g,
					b=b,
				}	
				if BYCOLOR then rgbstring = tostring(r*255)..tostring(g*255)..tostring(b*255) end
				if self.baseTable[rgbstring] == nil then self.baseTable[rgbstring] = {} end
				table.insert(self.baseTable[rgbstring],item)
			end
		end
	end
	self.state = 'buildHorizontal'
	currentProcessingState = currentProcessingState..'building horizontal table; screen may freeze periodically!'
end

function mask:buildHorizontal(dt)
	local horizontalTable = {}
	local baseTable = self.baseTable
	local BTCopy = deepcopy(baseTable)
	local items = 0
	for rgbname,color in pairs(baseTable) do
		for i=1,#color do	--we seem to be detecting a bunch of rects but are still eventually adding everything back to htable
			local item = shallowcopy(color[i])	--oops...
			for k=1,#BTCopy[rgbname] do
				if i ~= k and not color[i].skip then
					local o = BTCopy[rgbname][k]
					if not o.skip then
						if o.y == item.y and o.h == item.h and o.x == item.y+item.w then
							item.w = item.w + o.w
							o.skip = true
							color[k].skip = true
							items = items + 1
							print('adding width to '..tostring(item.x)..' '..tostring(item.y)..'from index '..tostring(k),items)
						end
					end
				end
			end
			if horizontalTable[rgbname] == nil then horizontalTable[rgbname] = {} end
			table.insert(horizontalTable[rgbname],item)
		end
	end
	currentProcessingState = currentProcessingState..'horizontal table built; drawing'
	_G.displayMap = horizontalTable
--	tablePrint(_G.displayMap)
	print('final item count: ',items)
	self.interface:changeState('mapDone')
	self.started = false
	self.state = 'done'
end

function mask:done(dt)

end

return mask