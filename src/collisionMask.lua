local mask = {}




function mask:loadMask(image,interface)--,world,parentMap,layer,layertoaddto)
	self.started = true
	self.interface = interface
	local w,h = image:getPixelDimensions()
	_G.displayCanvas = lg.newCanvas(w,h)
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
	local bT = self.baseTable
	--one baseTable; it looks like this
	--[[
	bT ={
			[red] = {
				[1] = {x = 0,y=0,w=4,h=4,rgb=rgb}
				[2] = {x = 4,y=0,w=4,h=4,rgb=rgb}
				[3] = {x = 8,y=0,w=4,h=4,rgb=rgb}
				[4] = {x = 12,y=0,w=4,h=4,rgb=rgb}
				[5] = {x = 16,y=0,w=4,h=4,rgb=rgb}
				[6] = {x = 20,y=0,w=4,h=4,rgb=rgb}
				[7] = {x = 24,y=0,w=4,h=4,rgb=rgb}
				[8] = {x = 28,y=0,w=4,h=4,rgb=rgb}
				[9] = {x = 0,y=4,w=4,h=4,rgb=rgb}
			}
		}
		we are using two versions so we don't have an issue
		the two addresses are:
		bT[color][ind] compared with bTCopy[color][ind]
	]]
	self.merges = 0
	self.totalRects = 0
	for rgb,color in pairs(bT) do
		for i,v in ipairs(color) do
			if not v.skip then	--no matter what we do, even if it doesn't get merged, it will get added
				--[[
					now i need to reiterate the same table
				]]
				v.skip = true
				for _,compare in ipairs(color) do
					if not compare.skip then
						--the first comparison is: is it next to me?
						if self:isNext(v,compare) then
							v.w = v.w + compare.w
							compare.skip = true
							self.merges = self.merges + 1
							print('merging',v.x,v.y,'with',compare.x,compare.y)
						end
					end
				end
				--add it to the end
				self.totalRects = self.totalRects + 1
				if horizontalTable[rgb] == nil then horizontalTable[rgb] = {} end
				table.insert(horizontalTable[rgb],v)
			end
		end
	end
	currentProcessingState = currentProcessingState..'horizontal table built; drawing'
	_G.displayMap = horizontalTable
	_G.merges = self.merges
	_G.totalRects = self.totalRects
	self.interface:changeState('mapDone')
	self.started = false
	self.state = 'done'
end

function mask:isNext(o,c)
	if o.y == c.y and ((o.x+o.w == c.x or o.x == c.x+c.w)) then return true end
end

function mask:buildHorizontal_old(dt)
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