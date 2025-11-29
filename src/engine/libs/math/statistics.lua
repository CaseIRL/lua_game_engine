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

--- @module maths.statistics
--- @description Statistical analysis functions for datasets

local m = {}

-- Epsilon for floating-point comparisons
local EPSILON = 1e-10

--- Validates that input is a non-empty table of numbers
--- @param numbers table The data to validate
--- @return boolean Valid
local function validate_numbers(numbers)
    if type(numbers) ~= "table" or #numbers == 0 then
        error("Input must be a non-empty table of numbers")
    end
    for i, v in ipairs(numbers) do
        if type(v) ~= "number" then
            error("All elements must be numbers (index " .. i .. " is " .. type(v) .. ")")
        end
    end
    return true
end

--- Validates that input is a non-empty table of points
--- @param points table The data to validate
--- @return boolean Valid
local function validate_points(points)
    if type(points) ~= "table" or #points == 0 then
        error("Input must be a non-empty table of points")
    end
    for i, p in ipairs(points) do
        if type(p) ~= "table" or type(p.x) ~= "number" or type(p.y) ~= "number" then
            error("All points must have x and y number fields (index " .. i .. " invalid)")
        end
    end
    return true
end

--- Calculates the mean (average) of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The mean value.
function m.mean(numbers)
    validate_numbers(numbers)
    local sum = 0
    for _, v in ipairs(numbers) do
        sum = sum + v
    end
    return sum / #numbers
end

--- Calculates the median of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The median value.
function m.median(numbers)
    validate_numbers(numbers)

    local sorted = {}
    for i, v in ipairs(numbers) do
        sorted[i] = v
    end
    table.sort(sorted)
    
    local n = #sorted
    if n % 2 == 0 then
        return (sorted[n / 2] + sorted[n / 2 + 1]) / 2
    else
        return sorted[math.ceil(n / 2)]
    end
end

--- Calculates the mode (most frequent value) of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number|nil The mode value, or nil if no clear mode exists.
function m.mode(numbers)
    validate_numbers(numbers)
    
    local counts = {}
    for _, v in ipairs(numbers) do
        counts[v] = (counts[v] or 0) + 1
    end
    
    local max_count = 0
    local mode_val = nil
    local mode_count = 0
    
    for v, count in pairs(counts) do
        if count > max_count then
            max_count = count
            mode_val = v
            mode_count = 1
        elseif count == max_count then
            mode_count = mode_count + 1
        end
    end

    if mode_count > 1 then
        return nil
    end
    
    return mode_val
end

--- Calculates the variance of a list of numbers.
--- @param numbers table The list of numbers.
--- @param population boolean If true, use population variance; if false (default), use sample variance.
--- @return number The variance.
function m.variance(numbers, population)
    validate_numbers(numbers)
    
    local mean_val = m.mean(numbers)
    local sum = 0
    
    for _, v in ipairs(numbers) do
        sum = sum + (v - mean_val) ^ 2
    end
    
    local divisor = population and #numbers or (#numbers - 1)
    if divisor == 0 then
        return 0
    end
    
    return sum / divisor
end

--- Calculates the standard deviation of a list of numbers.
--- @param numbers table The list of numbers.
--- @param population boolean If true, use population stddev; if false (default), use sample stddev.
--- @return number The standard deviation.
function m.standard_deviation(numbers, population)
    validate_numbers(numbers)
    return math.sqrt(m.variance(numbers, population))
end

--- Calculates the range (max - min) of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The range.
function m.range(numbers)
    validate_numbers(numbers)
    local min, max = numbers[1], numbers[1]
    for i = 2, #numbers do
        if numbers[i] < min then
            min = numbers[i]
        elseif numbers[i] > max then
            max = numbers[i]
        end
    end
    return max - min
end

--- Calculates the minimum value in a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The minimum value.
function m.min(numbers)
    validate_numbers(numbers)
    local min_val = numbers[1]
    for i = 2, #numbers do
        if numbers[i] < min_val then
            min_val = numbers[i]
        end
    end
    return min_val
end

--- Calculates the maximum value in a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The maximum value.
function m.max(numbers)
    validate_numbers(numbers)
    local max_val = numbers[1]
    for i = 2, #numbers do
        if numbers[i] > max_val then
            max_val = numbers[i]
        end
    end
    return max_val
end

--- Calculates the sum of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The sum.
function m.sum(numbers)
    validate_numbers(numbers)
    local sum = 0
    for _, v in ipairs(numbers) do
        sum = sum + v
    end
    return sum
end

--- Calculates the quantile (percentile) of a list of numbers.
--- @param numbers table The list of numbers.
--- @param q number The quantile (0.0 to 1.0, where 0.5 is the median).
--- @return number The quantile value.
function m.quantile(numbers, q)
    validate_numbers(numbers)
    
    if type(q) ~= "number" or q < 0 or q > 1 then
        error("Quantile must be a number between 0.0 and 1.0")
    end
    
    local sorted = {}
    for i, v in ipairs(numbers) do
        sorted[i] = v
    end
    table.sort(sorted)
    
    local n = #sorted
    local index = q * (n - 1) + 1
    local lower_idx = math.floor(index)
    local upper_idx = math.ceil(index)
    
    if lower_idx == upper_idx then
        return sorted[lower_idx]
    end
    
    local fraction = index - lower_idx
    return sorted[lower_idx] * (1 - fraction) + sorted[upper_idx] * fraction
end

--- Performs linear regression on a list of 2D points.
--- @param points table The list of points with {x=number, y=number}.
--- @return table Result with {slope=number, intercept=number, r_squared=number}.
function m.linear_regression(points)
    validate_points(points)
    
    local n = #points
    local sum_x, sum_y, sum_xx, sum_xy, sum_yy = 0, 0, 0, 0, 0
    
    for _, p in ipairs(points) do
        sum_x = sum_x + p.x
        sum_y = sum_y + p.y
        sum_xx = sum_xx + p.x * p.x
        sum_xy = sum_xy + p.x * p.y
        sum_yy = sum_yy + p.y * p.y
    end
    
    local denominator = n * sum_xx - sum_x * sum_x
    
    if math.abs(denominator) < EPSILON then
        error("Cannot perform linear regression: points are collinear or insufficient variance")
    end
    
    local slope = (n * sum_xy - sum_x * sum_y) / denominator
    local intercept = (sum_y - slope * sum_x) / n

    local numerator = (n * sum_xy - sum_x * sum_y) ^ 2
    local r_squared = numerator / (denominator * (n * sum_yy - sum_y * sum_y))
    
    return {
        slope = slope,
        intercept = intercept,
        r_squared = math.max(0, math.min(1, r_squared))
    }
end

--- Calculates the correlation coefficient between two datasets.
--- @param x table The first dataset.
--- @param y table The second dataset.
--- @return number The Pearson correlation coefficient (-1 to 1).
function m.correlation(x, y)
    if type(x) ~= "table" or type(y) ~= "table" or #x ~= #y or #x == 0 then
        error("Both inputs must be non-empty tables of equal length")
    end
    
    for i, v in ipairs(x) do
        if type(v) ~= "number" or type(y[i]) ~= "number" then
            error("All elements must be numbers")
        end
    end
    
    local mean_x = m.mean(x)
    local mean_y = m.mean(y)
    local cov = 0
    local var_x = 0
    local var_y = 0
    
    for i = 1, #x do
        local dx = x[i] - mean_x
        local dy = y[i] - mean_y
        cov = cov + dx * dy
        var_x = var_x + dx * dx
        var_y = var_y + dy * dy
    end
    
    if math.abs(var_x) < EPSILON or math.abs(var_y) < EPSILON then
        return 0
    end
    
    return cov / math.sqrt(var_x * var_y)
end

--- Calculates the covariance between two datasets.
--- @param x table The first dataset.
--- @param y table The second dataset.
--- @param population boolean If true, use population covariance; if false (default), use sample covariance.
--- @return number The covariance.
function m.covariance(x, y, population)
    if type(x) ~= "table" or type(y) ~= "table" or #x ~= #y or #x == 0 then
        error("Both inputs must be non-empty tables of equal length")
    end
    
    for i, v in ipairs(x) do
        if type(v) ~= "number" or type(y[i]) ~= "number" then
            error("All elements must be numbers")
        end
    end
    
    local mean_x = m.mean(x)
    local mean_y = m.mean(y)
    local sum = 0
    
    for i = 1, #x do
        sum = sum + (x[i] - mean_x) * (y[i] - mean_y)
    end
    
    local divisor = population and #x or (#x - 1)
    if divisor == 0 then
        return 0
    end
    
    return sum / divisor
end

return m