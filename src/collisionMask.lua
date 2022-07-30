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
	self.merges = 0
	self.totalRects = 0
	for rgb,color in pairs(bT) do
		for i,v in ipairs(color) do
			if not v.hskip then
				v.hskip = true
				for _,compare in ipairs(color) do
					if not compare.hskip then
						if self:isNext(v,compare) then
							v.w = v.w + compare.w
							compare.hskip = true
							self.merges = self.merges + 1
						end
					end
				end
				self.totalRects = self.totalRects + 1
				if horizontalTable[rgb] == nil then horizontalTable[rgb] = {} end
				table.insert(horizontalTable[rgb],v)
			end
		end
	end
	if horizontalOnly then
		_G.displayMap = horizontalTable
		_G.merges = self.merges
		_G.totalRects = self.totalRects
		self.interface:changeState('mapDone')
		self.started = false
		self.state = 'done'
	else
		currentProcessingState = currentProcessingState..'horizontal table built; \nbuilding verticals'
		self.horizontalTable = horizontalTable
		self.state = 'buildVertical'
	end
	
end
horizontalOnly = false
function mask:buildVertical(dt)
	self.totalRects = 0
	local verticalTable = {}
	local hT = self.horizontalTable
	for rgb,color in pairs(hT) do
		for i,v in ipairs(color) do
			if not v.vskip then
				v.vskip = true
				for _,compare in ipairs(color) do
					if not compare.vskip then
						if self:isVertical(v,compare) then
							v.h = v.h + compare.h
							compare.vskip = true
							self.merges = self.merges + 1
						end
					end
				end		
				self.totalRects = self.totalRects + 1
				if verticalTable[rgb]==nil then verticalTable[rgb] = {} end
				table.insert(verticalTable[rgb],v)
			end
		end
	end
	currentProcessingState = currentProcessingState..'vertical table built; drawing'
	local processedTable = self:removeNoise(verticalTable)
	_G.displayMap = processedTable
	_G.merges = self.merges
	_G.totalRects = self.totalRects
	self.interface:changeState('mapDone')
	self.started = false
	self.state = 'done'
end


function mask:isNext(o,c)
	if o.y == c.y and o.h == c.h and ((o.x+o.w == c.x or o.x == c.x+c.w)) then return true end
end
function mask:isVertical(o,c)
	if o.x == c.x and o.w == c.w and ((o.y+o.h == c.y or o.y == c.y+c.h)) then return true end
end
function mask:removeNoise(t)
	local flattened = {}
	for rgb,color in pairs(t) do
		for i,v in ipairs(color) do
			v.hskip = nil
			v.vskip = nil
			table.insert(flattened,v)
		end
	end
	return flattened
end

function mask:done(dt)

end

return mask