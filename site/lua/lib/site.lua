local json = require("cjson").new()
local http = require("resty.http")
local String = require("util.string")
local config = require("lib.config")
local shared_data = ngx.shared.shared_data

local _M = {}

function _M.get_site_data()
    local data = shared_data:get("site_data")
    if String.isNotEmpty(data) then
        return json.decode(data)
    end

    local type = shared_data:get("site_type")
    if type == "notion" then
        local notion_token = shared_data:get("notion_token")
        local notion = require("lib.notion").new(notion_token)
        data = notion:get_site_data()
        shared_data:set("site_data", json.encode(data), config.notion_expire_time)
    end

    return data
end

function _M.get_hitokoto()
    local data = shared_data:get("hitokoto")
    if String.isNotEmpty(data) then
        return json.decode(data)
    end

    data = {}

    local httpc = http.new()
    local res, err = httpc:request_uri("https://v1.hitokoto.cn", {
        ssl_verify = false
    })
    if not res then
        ngx.log(ngx.ERR, "request failed: ", err)
        return {}
    end

    local status = res.status
    if status ~= 200 then
        ngx.log(ngx.ERR, "request failed status: ", status)
        return {}
    end

    local body = json.decode(res.body)
    data.uuid = body.uuid
    data.hitokoto = body.hitokoto
    shared_data:set("hitokoto", json.encode(data), config.hitokoto_expire_time)
    return data
end

return _M
