function createWall(w, tx, ty)
	local wall1 = {}
	wall1.body = love.physics.newBody(mundo, TX/2, 0)
	wall1.shape = love.physics.newRectangleShape(TX, 1)
	wall1.fixture = love.physics.newFixture(wall1.body, wall1.shape)

	local wall2 = {}
	wall2.body = love.physics.newBody(mundo, TX/2, TY - 25)
	wall2.shape = love.physics.newRectangleShape(TX, 1)
	wall2.fixture = love.physics.newFixture(wall2.body, wall2.shape)

	local wall3 = {}
	wall3.body = love.physics.newBody(mundo, 0, TY/2)
	wall3.shape = love.physics.newRectangleShape(1, TX)
	wall3.fixture = love.physics.newFixture(wall3.body, wall3.shape)

	local wall4 = {}
	wall4.body = love.physics.newBody(mundo, TX, TY/2)
	wall4.shape = love.physics.newRectangleShape(1, TX)
	wall4.fixture = love.physics.newFixture(wall4.body, wall4.shape)

	return {wall1, wall2, wall3, wall4}
end