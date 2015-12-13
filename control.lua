function distance(x1, y1, x2, y2)
	return math.sqrt( (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2))
end

function max(n, max)
	if n < max then
		return n
	end
	return max
end

function min(n, min)
	if n > min then
		return n
	end
	return min
end

function mouseg(t)
	if t == 'help' then
		if love.mouse.getX() > 0 and love.mouse.getX() < 40 and love.mouse.getY() > TY - 25 and love.mouse.getY() < TY then
			return true
		end
	end
	if t == 'cores' then
		if love.mouse.getX() > 50 and love.mouse.getX() < 100 and love.mouse.getY() > TY - 25 and love.mouse.getY() < TY then
			return true
		end
	end
end

function pertence(n, tab)
	for i = 1, #tab, 1 do
		if tab[i] == n then
			return i
		end
	end
	return false
end