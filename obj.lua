obj = {}
obj.body = nil
obj.shape = nil
obj.fixture = nil
obj.cor1 = 255
obj.cor2 = 255
obj.cor3 = 255

function obj:new(n)
	n = n or {}
	setmetatable(n, self)
	self.__index = self
	return n
end