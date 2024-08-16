local util = {
    _VERSION = "0.3",
    array = require("util.array"),
    func = require("util.function"),
    object = require("util.object"),
    string = require("util.string")
}

function util.try(fns, catch)
    if not catch or type(catch) ~= "function" then
        catch = function(err) return nil, err end
    end

    local res
    local err

    for _, fn in ipairs(fns) do
        res, err = fn(res)

        if err then return catch(err) end
    end

    return res
end

function util.noop() end

function util.once(fn)
    local done = false

    return function(...)
        if done then
            return
        else
            done = true
            return util.func.apply(fn, {...})
        end
    end
end

return util
