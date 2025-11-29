--[[
    Support honest development retain this credit. 
    Don't claim you made it from scratch. Don't be that guy...

    MIT License

    Copyright (c) 2025 CaseIRL

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

--- @module maths.probability
--- @description Probability and random helpers.

local m = {}

-- Epsilon for floating-point comparisons
local EPSILON = 1e-10

--- Set the random seed for reproducibility
--- @param seed number Seed value for RNG
function m.set_seed(seed)
    if type(seed) ~= "number" then
        error("Seed must be a number")
    end
    math.randomseed(seed)
end

--- Returns a random float between min and max.
--- @param min number Lower bound.
--- @param max number Upper bound.
--- @param rand_func? function Optional RNG function returning 0.0–1.0 (default math.random).
--- @return number Random float in the range [min, max].
function m.random_between(min, max, rand_func)
    if type(min) ~= "number" or type(max) ~= "number" then
        error("Min and max must be numbers")
    end
    
    if min > max then
        min, max = max, min
    end
    
    rand_func = rand_func or math.random
    return min + rand_func() * (max - min)
end

--- Returns a random integer between min and max (inclusive).
--- @param min number Lower bound.
--- @param max number Upper bound.
--- @param rand_func? function Optional RNG function returning 0.0–1.0.
--- @return number Random integer in the range [min, max].
function m.random_int(min, max, rand_func)
    if type(min) ~= "number" or type(max) ~= "number" then
        error("Min and max must be numbers")
    end
    
    min, max = math.floor(min), math.floor(max)
    
    if min > max then
        min, max = max, min
    end
    
    if min == max then
        return min
    end
    
    rand_func = rand_func or math.random
    return math.floor(rand_func() * (max - min + 1)) + min
end

--- Check if something happens with a given probability (0.0 to 1.0)
--- @param probability number Chance of success (0.0 to 1.0)
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return boolean True if the event occurs
function m.chance(probability, rand_func)
    if type(probability) ~= "number" then
        error("Probability must be a number")
    end
    
    if probability < 0 or probability > 1 then
        error("Probability must be between 0.0 and 1.0")
    end
    
    rand_func = rand_func or math.random
    return rand_func() < probability
end

--- Check if something happens with a given percentage chance (0 to 100)
--- @param percentage number Chance of success (0 to 100)
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return boolean True if the event occurs
function m.percent_chance(percentage, rand_func)
    if type(percentage) ~= "number" then
        error("Percentage must be a number")
    end
    
    if percentage < 0 or percentage > 100 then
        error("Percentage must be between 0 and 100")
    end
    
    return m.chance(percentage / 100, rand_func)
end

--- Select a random element from a table with uniform probability
--- @param tbl table Table to select from
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return any|nil Random element, or nil if table is empty
function m.random_choice(tbl, rand_func)
    if type(tbl) ~= "table" or #tbl == 0 then
        return nil
    end
    
    rand_func = rand_func or math.random
    local index = math.floor(rand_func() * #tbl) + 1
    return tbl[index]
end

--- Selects a random choice from a mapping of options with weights.
--- @param map table Table of weighted options `{ option = weight, ... }`.
--- @param rand_func? function Optional RNG function returning 0.0–1.0.
--- @return any|nil The chosen option key, or nil if all weights <= 0.
function m.weighted_choice(map, rand_func)
    if type(map) ~= "table" then
        error("Map must be a table")
    end
    
    rand_func = rand_func or math.random
    
    local total = 0
    for _, w in pairs(map) do
        if type(w) ~= "number" then
            error("All weights must be numbers")
        end
        if w > 0 then
            total = total + w
        end
    end
    
    if total < EPSILON then
        return nil
    end
    
    local thresh = rand_func() * total
    local cumulative = 0
    
    for key, w in pairs(map) do
        if w > 0 then
            cumulative = cumulative + w
            if thresh < cumulative then
                return key
            end
        end
    end

    for key, w in pairs(map) do
        if w > 0 then
            local last_key = key
            for k, wt in pairs(map) do
                if wt > 0 then
                    last_key = k
                end
            end
            return last_key
        end
    end
    
    return nil
end

--- Shuffle a table in-place using Fisher-Yates algorithm
--- @param tbl table Table to shuffle
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return table The shuffled table (same reference)
function m.shuffle(tbl, rand_func)
    if type(tbl) ~= "table" then
        error("Input must be a table")
    end
    
    rand_func = rand_func or math.random
    
    for i = #tbl, 2, -1 do
        local j = math.floor(rand_func() * i) + 1
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    
    return tbl
end

--- Generate a random value from a normal (Gaussian) distribution
--- @param mean number Mean of the distribution (default 0)
--- @param stddev number Standard deviation (default 1)
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return number Random value from normal distribution
function m.random_normal(mean, stddev, rand_func)
    mean = mean or 0
    stddev = stddev or 1
    
    if type(mean) ~= "number" or type(stddev) ~= "number" then
        error("Mean and stddev must be numbers")
    end
    
    if stddev <= 0 then
        error("Standard deviation must be positive")
    end
    
    rand_func = rand_func or math.random

    local u1 = rand_func()
    local u2 = rand_func()

    while u1 < EPSILON do
        u1 = rand_func()
    end
    
    local z0 = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return mean + z0 * stddev
end

--- Generate a random value from an exponential distribution
--- @param lambda number Rate parameter (lambda > 0)
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return number Random value from exponential distribution
function m.random_exponential(lambda, rand_func)
    if type(lambda) ~= "number" or lambda <= 0 then
        error("Lambda must be a positive number")
    end
    
    rand_func = rand_func or math.random
    
    local u = rand_func()
    while u < EPSILON do
        u = rand_func()
    end
    
    return -math.log(u) / lambda
end

--- Generate a random value from a uniform distribution (same as random_between)
--- @param min number Lower bound
--- @param max number Upper bound
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return number Random value from uniform distribution
function m.random_uniform(min, max, rand_func)
    return m.random_between(min, max, rand_func)
end

return m