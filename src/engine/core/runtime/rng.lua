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

--- @module runtime.rng
--- @description Deterministic RNG wrapper using a Linear Congruential Generator (LCG).

local m = {}

-- LCG state
local seed = os.time()
local state = seed

local MODULUS = 2^31
local MULTIPLIER = 1103515245
local INCREMENT = 12345

--- Sets the seed for RNG.
--- @param s number: Seed to use (default: current time).
function m.set_rng_seed(s)
    seed = s or os.time()
    state = seed
end

--- Gets the current seed value.
--- @return number: The last set seed value.
function m.get_rng_seed()
    return seed
end

--- Returns a raw float between 0.0 and 1.0.
--- @return number: Random float between 0.0 and 1.0.
function m.random_rng()
    state = (MULTIPLIER * state + INCREMENT) % MODULUS
    return state / MODULUS
end

--- Gets the internal RNG state for snapshot/rewind functionality.
--- @return number: Current internal RNG state.
function m.get_rng_state()
    return state
end

--- Restores a previously saved RNG state.
--- @param s number: State value to restore.
function m.set_rng_state(s)
    state = s
end

return m