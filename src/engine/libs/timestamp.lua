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

--- @module engine.libs.timestamp
--- @description Timestamp and date/time utilities

local m = {}

--- Converts a UNIX timestamp (seconds) to date/time components.
--- @param ts number UNIX timestamp in seconds (default: current time)
--- @return table Table with date, time, and both combined
function m.convert_timestamp(ts)
    ts = ts or os.time()
    return {
        date = os.date("%Y-%m-%d", ts),
        time = os.date("%H:%M:%S", ts),
        both = os.date("%Y-%m-%d %H:%M:%S", ts)
    }
end

--- Gets the current UNIX timestamp.
--- @return number Current time in seconds since epoch
function m.now()
    return os.time()
end

--- Gets the current date and time as formatted strings.
--- @return string, string Date as "YYYY-MM-DD" and time as "HH:MM:SS"
function m.now_formatted()
    local ts = os.time()
    return os.date("%Y-%m-%d", ts), os.date("%H:%M:%S", ts)
end

--- Calculates the difference in days between two dates.
--- @param start_date string Start date in "YYYY-MM-DD" format
--- @param end_date string End date in "YYYY-MM-DD" format
--- @return number The absolute number of days between the two dates
function m.date_difference(start_date, end_date)
    local sy, sm, sd = start_date:match("(%d+)%-(%d+)%-(%d+)")
    local ey, em, ed = end_date:match("(%d+)%-(%d+)%-(%d+)")
    local t1 = os.time{ year = tonumber(sy), month = tonumber(sm), day = tonumber(sd) }
    local t2 = os.time{ year = tonumber(ey), month = tonumber(em), day = tonumber(ed) }
    local diff = math.abs(os.difftime(t2, t1))
    return math.floor(diff / (24 * 60 * 60))
end

--- Calculates the difference in seconds between two timestamps.
--- @param ts1 number First timestamp
--- @param ts2 number Second timestamp
--- @return number Difference in seconds (absolute value)
function m.timestamp_difference(ts1, ts2)
    return math.abs(os.difftime(ts2, ts1))
end

--- Adds a number of days to a date string.
--- @param date_str string Date in "YYYY-MM-DD" format
--- @param days number Number of days to add (can be negative)
--- @return string New date in "YYYY-MM-DD" format
function m.add_days_to_date(date_str, days)
    local y, m, d = date_str:match("(%d+)%-(%d+)%-(%d+)")
    local time = os.time{ year = tonumber(y), month = tonumber(m), day = tonumber(d) }
    local new_time = time + (days * 24 * 60 * 60)
    return os.date("%Y-%m-%d", new_time)
end

--- Adds a number of seconds to a timestamp.
--- @param ts number UNIX timestamp
--- @param seconds number Seconds to add (can be negative)
--- @return number New timestamp
function m.add_seconds(ts, seconds)
    return ts + seconds
end

--- Adds a number of hours to a timestamp.
--- @param ts number UNIX timestamp
--- @param hours number Hours to add (can be negative)
--- @return number New timestamp
function m.add_hours(ts, hours)
    return ts + (hours * 60 * 60)
end

--- Adds a number of minutes to a timestamp.
--- @param ts number UNIX timestamp
--- @param minutes number Minutes to add (can be negative)
--- @return number New timestamp
function m.add_minutes(ts, minutes)
    return ts + (minutes * 60)
end

--- Formats a timestamp with custom format string.
--- @param ts number UNIX timestamp
--- @param format string Format string (see os.date for patterns)
--- @return string Formatted timestamp
function m.format_timestamp(ts, format)
    ts = ts or os.time()
    return os.date(format, ts)
end

--- Gets the day of week for a timestamp (1=Sunday, 7=Saturday).
--- @param ts number UNIX timestamp
--- @return number Day of week
function m.day_of_week(ts)
    ts = ts or os.time()
    return tonumber(os.date("%w", ts)) + 1
end

--- Gets the day of week name for a timestamp.
--- @param ts number UNIX timestamp
--- @return string Day name (e.g., "Monday")
function m.day_name(ts)
    local days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
    return days[m.day_of_week(ts)]
end

--- Gets the month name for a timestamp.
--- @param ts number UNIX timestamp
--- @return string Month name (e.g., "January")
function m.month_name(ts)
    local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
    local month = tonumber(os.date("%m", ts))
    return months[month]
end

--- Checks if a given year is a leap year.
--- @param year number The year to check
--- @return boolean True if leap year
function m.is_leap_year(year)
    return (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
end

--- Gets the number of days in a month.
--- @param year number The year
--- @param month number The month (1-12)
--- @return number Number of days in the month
function m.days_in_month(year, month)
    local days_in = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    if month == 2 and m.is_leap_year(year) then
        return 29
    end
    return days_in[month]
end

--- Parses a date string into timestamp.
--- @param date_str string Date in "YYYY-MM-DD" format
--- @param time_str string? Time in "HH:MM:SS" format (default: "00:00:00")
--- @return number UNIX timestamp
function m.parse_date(date_str, time_str)
    time_str = time_str or "00:00:00"
    local y, m, d = date_str:match("(%d+)%-(%d+)%-(%d+)")
    local h, min, s = time_str:match("(%d+):(%d+):(%d+)")
    
    return os.time{
        year = tonumber(y),
        month = tonumber(m),
        day = tonumber(d),
        hour = tonumber(h) or 0,
        min = tonumber(min) or 0,
        sec = tonumber(s) or 0
    }
end

--- Checks if a timestamp is in the past.
--- @param ts number UNIX timestamp to check
--- @return boolean True if timestamp is in the past
function m.is_past(ts)
    return ts < os.time()
end

--- Checks if a timestamp is in the future.
--- @param ts number UNIX timestamp to check
--- @return boolean True if timestamp is in the future
function m.is_future(ts)
    return ts > os.time()
end

--- Formats a time duration in seconds to human readable string.
--- @param seconds number Duration in seconds
--- @return string Human readable duration (e.g., "2h 30m 15s")
function m.format_duration(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    local parts = {}
    if hours > 0 then table.insert(parts, hours .. "h") end
    if minutes > 0 then table.insert(parts, minutes .. "m") end
    if secs > 0 or #parts == 0 then table.insert(parts, secs .. "s") end
    
    return table.concat(parts, " ")
end

return m