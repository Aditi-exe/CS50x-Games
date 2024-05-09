--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]

require 'Util'

Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = -1

-- cloud tiles
CLOUD_LEFT = 6
CLOUD_RIGHT = 7

-- bush tiles
BUSH_LEFT = 2
BUSH_RIGHT = 3

-- mushroom tiles
MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

-- jump block
JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

-- pyramid brick
PYRAMID_BRICK = 1

-- flag tiles
FLAG_TOP = 8
FLAG_POLE = 12
FLAG_BASE = 16
FLAG = 13

-- a speed to multiply delta time to scroll map; smooth value
local SCROLL_SPEED = 62

-- pyramid height increment variable
height = 0

-- constructor for our map object
function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.sprites = generateQuads(self.spritesheet, 16, 16)
    self.music = love.audio.newSource('sounds/music.wav', 'static')

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 80
    self.mapHeight = 28
    self.tiles = {}

    -- applies positive Y influence on anything affected
    self.gravity = 15

    -- associate player with map
    self.player = Player(self)

    -- camera offsets
    self.camX = 0
    self.camY = -3

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- begin generating the terrain using vertical scan lines
    local x = 1
    while x < self.mapWidth do
        
        -- 2% chance to generate a cloud
        -- make sure we're 2 tiles from edge at least
        if x < self.mapWidth - 2 then
            if math.random(20) == 1 then
                
                -- choose a random vertical spot above where blocks/pipes generate
                local cloudStart = math.random(self.mapHeight / 2 - 6)

                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        -- 5% chance to generate a mushroom
        if math.random(20) == 1 then
            -- left side of pipe
            self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
            self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_BOTTOM)

            -- creates column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            -- next vertical scan line
            x = x + 1

        -- 10% chance to generate bush, being sure to generate away from edge
        elseif math.random(10) == 1 and x < self.mapWidth - 3 then
            local bushLevel = self.mapHeight / 2 - 1

            -- place bush component and then column of bricks
            self:setTile(x, bushLevel, BUSH_LEFT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

            self:setTile(x, bushLevel, BUSH_RIGHT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

        -- 10% chance to not generate anything, creating a gap
        elseif math.random(10) ~= 1 then
            
            -- creates column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            -- chance to create a block for Mario to hit
            if math.random(15) == 1 then
                self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
            end

            -- next vertical scan line
            x = x + 1
        else
            -- increment X so we skip two scanlines, creating a 2-tile gap
            x = x + 2
        end


        -- generating the pyramid
        count = 0
        i = 0
        for x = self.mapWidth - 20, self.mapWidth - 20 + 5, 1 do
            -- first iteration
            count = count + 1
            while i <= count do
                for y = self.mapHeight / 2, self.mapHeight / 2 - i, -1 do
                    self:setTile(x, y, TILE_BRICK)
                end
                i = i + 1
            end
        end

        if x == self.mapWidth - 20 + 5 + 4 then
            flag_base = self.mapHeight / 2
            flag_pole_bottom = self.mapHeight / 2 - 1
            flag_pole_top = self.mapHeight / 2 - 2
            flag_top = self.mapHeight / 2 - 3
            flag = self.mapWidth - 20 + 5 + 5

            self:setTile(x, flag_base, FLAG_BASE)
            self:setTile(x, flag_pole_bottom, FLAG_POLE)
            self:setTile(x, flag_pole_top, FLAG_POLE)
            self:setTile(x, flag_top, FLAG_TOP)
            self:setTile(flag, flag_top, FLAG)
        end




        --[[
        while x == self.mapWidth - 20 + 8 do

            for y = self.mapHeight / 2, self.mapHeight / 2 - 1, -1 do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1

            for y = self.mapHeight / 2, self.mapHeight / 2 - 2, -1 do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1
            
            for y = self.mapHeight / 2, self.mapHeight / 2 - 3, -1 do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1

            for y = self.mapHeight / 2, self.mapHeight / 2 - 4, -1 do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1

            for y = self.mapHeight / 2, self.mapHeight / 2 - 5, -1 do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1

            for y = self.mapHeight / 2, self.mapHeight / 2 - 6, -1 do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1

            for y = self.mapHeight / 2, self.mapHeight / 2 - 7, -1 do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1

            for y = self.mapHeight / 2, self.mapHeight / 2 - 8, -1 do
                self:setTile(x, y, TILE_BRICK)
            end
        end
        ]]


        --[[
        for x = self.mapWidth - 10, self.mapWidth - 10 + 4, 1 do
            i = 1
            for y = self.mapHeight / 2, self.mapHeight / 2 - i, -1 do
                self:setTile(x, y, TILE_BRICK)
            end
            i = i + 1
        end
        ]]

        --[[
        -- MAKES A BLOCK
        -- WE'RE GETTING THERE
        for x = self.mapWidth - 10, self.mapWidth - 10 + 4, 1 do
            for i = 0, 4, 1 do
                for y = self.mapHeight / 2, self.mapHeight / 2 - i, -1 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end
        end
        ]]
            



        --[[
        -- MAKES HOLLOW PYRAMID
        -- generating the pyramid: 4 tiles high
        -- making sure we're at least 10 tiles away from the end of the level
        height = self.mapHeight / 2
        for x = self.mapWidth - 10, self.mapWidth - 10 + 4, 1 do
            self:setTile(x, height, TILE_BRICK)
            height = height - 1
        end
        ]]

        --[[
            -- DOESNT WORK AT ALL
        column = self.mapHeight / 2
        for row = self.mapWidth - 10, self.mapWidth - 10 + 4, 1 do
            for column = self.mapHeight / 2, column + height, 1 do
                self:setTile(row, column, TILE_BRICK)
            end
            height = height + 1
        end
        ]]

        --[[
        -- MAKES HOLLOW PYRAMID
        -- generating the pyramid: 4 tiles high
        -- making sure we're at least 10 tiles away from the end of the level
        height = self.mapHeight / 2
        for x = self.mapWidth - 10, self.mapWidth - 10 + 4, 1 do
            self:setTile(x, height, TILE_BRICK)
            height = height - 1
        end
        ]]


        --[[
            for y = self.mapHeight / 2, self.mapHeight / 2 - 4, -1 do
                for i = 0, 4, 1 do
                    for j = 0, i, 1 do
                        self:setTile(x, y, TILE_BRICK)
                    end
                end
            end
        end
        
        ]]


        --[[ 
        -- make sure we're 5 tiles from edge at least
        if x < self.mapWidth - 5 then
            if math.random(1) == 1 then
                -- level of pyramid; height of pyramid is 8, so begin making pyramid from 8 tiles above ground
                pyramid_level = self.mapHeight / 2 - 4
                h = 4
                while pyramid_level <= self.mapHeight do
                    for i = 1, h, 1 do
                        for j = h - 1, i, -1 do
                            self:setTile(x, pyramid_level, TILE_EMPTY)
                        end
                        for k = 1, i, 1 do
                            self:setTile(x + 1, pyramid_level, PYRAMID_BRICK)
                        end
                        self:setTile(x, pyramid_level, TILE_EMPTY)
                    end
                    pyramid_level = pyramid_level + 1
                end
            end
        end
        ]]
        
    end


    -- start the background music
    self.music:setLooping(true)
    self.music:play()
end

-- return whether a given tile is collidable
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM
    }

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

-- function to update camera offset with delta time
function Map:update(dt)
    self.player:update(dt)
    
    -- keep camera's X coordinate following the player, preventing camera from
    -- scrolling past 0 to the left and the map's width
    self.camX = math.max(0, math.min(self.player.x - VIRTUAL_WIDTH / 2,
        math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))
end

-- gets the tile type at a given pixel coordinate
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

-- displays the winning message
function Map:winnerMessage()
    love.audio.stop()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 10))
    love.graphics.clear(5 / 255, 55 / 255, 99 / 255)
    --love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('You have completed Super Mario! :D', self.mapWidthPixels - 310, self.mapHeightPixels / 2 - 140)
end

-- renders our map to the screen, to be called by main's render
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.sprites[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    self.player:render()
        
    

end
