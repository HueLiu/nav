local shared_data = ngx.shared.shared_data
local json = require("cjson").new()
local http = require("resty.http")
local String = require("util.string")
local setmetatable = setmetatable

local _M = {
    base_url = "https://api.notion.com/v1/"
}
local mt = {
    __index = _M
}

function _M.new(notion_token)
    local header = {
        ["Notion-Version"] = "2022-06-28",
        ["Content-Type"] = "application/json"
    }
    if String.isNotEmpty(notion_token) then
        header.Authorization = "Bearer " .. notion_token
    end

    return setmetatable({
        header = header
    }, mt)
end

function _M.request(self, url, config)
    local httpc = http.new()

    -- Single-shot requests use the `request_uri` interface.
    config.headers = self.header
    config.ssl_verify = false
    local res, err = httpc:request_uri(url, config)
    if not res or err then
        ngx.log(ngx.ERR, "request failed: ", err)
        return
    end

    local status = res.status
    if status ~= 200 then
        ngx.log(ngx.ERR, "request failed status: ", status, err, url)
        return
    end

    return res.body
end

function _M.get(self, url, config)
    config = config or {}
    config.method = "GET"
    return self:request(url, config)
end

function _M.post(self, url, config)
    config = config or {}
    config.method = "POST"
    return self:request(url, config)
end

function _M.retriveAllBlocks(self, page_id)
    return self:get(_M.base_url .. "blocks/" .. page_id .. "/children")
end

function _M.retriveDatabase(self, database_id)
    return self:get(_M.base_url .. "databases/" .. database_id)
end

function _M.queryDatabase(self, database_id, body)
    return self:post(_M.base_url .. "databases/" .. database_id .. "/query", {
        body = body
    })
end

function _M.get_databases(self, page_id)
    -- 获取当前页面下的所有内容块
    local blocks_data = self:retriveAllBlocks(page_id)

    if String.isEmpty(blocks_data) then
        ngx.log(ngx.ERR, "获取notion页面的内容块失败, page_id:", page_id)
        return
    end

    local blocks = json.decode(blocks_data)
    if String.isEmpty(blocks) or String.isEmpty(blocks.results) then
        ngx.log(ngx.ERR, "notion页面的内容json解析失败, blocks_data:", blocks_data)
        return
    end

    local databases = {}
    for key, block in pairs(blocks.results) do
        if block.type == "child_database" then
            databases[block.child_database.title] = block.id
        end
    end

    return databases
end

function _M.get_site_data(self)
    local database_id = shared_data:get("notion_database")
    local body = {
        sorts = {{
            property = "value",
            direction = "ascending"
        }}
    }

    local site = {}
    local category_dict = {}
    local sidebar_footer = {}
    local content_header_dict = {}
    local content_search_dict = {}
    local content_search = {}
    local links_dict = {}
    local friends = {}

    while (true) do
        local res = self:queryDatabase(database_id, json.encode(body))
        if String.isEmpty(res) then
            ngx.log(ngx.ERR, "导航网站未配置")
            return
        end

        local data = json.decode(res)
        for key, row in pairs(data.results) do
            local select = row.properties.type.select
            if String.isNotEmpty(select) then
                local type = select.name
                if type == "site" then
                    -- 数据库字段： name | value | description
                    local name = row.properties.name.title[1].plain_text
                    local value = row.properties.value.rich_text[1].plain_text
                    site[name] = value
                elseif type == "category" then
                    get_category(category_dict, row)
                elseif type == "sidebar_footer" then
                    table.insert(sidebar_footer, get_sidebar_footer(row))
                elseif type == "content_header" then
                    get_category(content_header_dict, row)
                elseif type == "content_search" then
                    get_category(content_search_dict, row)
                elseif type == "link" then
                    get_link(links_dict, row)
                elseif type == "friend" then
                    get_friend(friends, row)
                end
            end
        end

        if data.has_more and data.next_cursor then
            body.start_cursor = data.next_cursor
        else
            break
        end
    end

    local categories = {}
    for code, category in pairs(category_dict) do
        table.insert(categories, category)
    end
    table.sort(categories, sortFunction)

    for key, category in pairs(categories) do
        if not category.children or #category.children == 0 then
            category.links = links_dict[category.name] or {}
        else
            for child_key, child_category in pairs(category.children) do
                child_category.links = links_dict[child_category.name] or {}
            end
        end
    end

    table.sort(sidebar_footer, sortFunction)

    local content_header = {}
    for code, category in pairs(content_header_dict) do
        table.insert(content_header, category)
    end
    table.sort(content_header, sortFunction)

    local content_search = {}
    for code, category in pairs(content_search_dict) do
        table.insert(content_search, category)
    end
    table.sort(content_search, sortFunction)

    return {
        site = site,
        categories = categories,
        sidebar_footer = sidebar_footer,
        content_header = content_header,
        content_search = content_search,
        friends = friends
    }
end

-- 数据库字段： value | name | icon | url | description
function get_category(category_dict, row)
    local code = row.properties.value.rich_text[1].plain_text
    local name = row.properties.name.title[1].plain_text
    local icon_rich_text = row.properties.icon.rich_text
    local icon = icon_rich_text[1] and icon_rich_text[1].plain_text or ngx.null
    local url = row.properties.url.url
    local description_rich_text = row.properties.description.rich_text
    local description = description_rich_text[1] and description_rich_text[1].plain_text or ngx.null

    if string.len(code) == 2 then
        local category = category_dict[code] or {}
        category.code = code
        category.name = name
        category.icon = icon
        category.url = url
        category.description = description
        category_dict[code] = category
    else
        local parent_code = string.sub(code, 1, 2)
        local parent_category = category_dict[parent_code] or {}
        local parent_category_children = parent_category.children or {}
        table.insert(parent_category_children, {
            code = code,
            name = name,
            icon = icon,
            url = url,
            description = description
        })
        parent_category.children = parent_category_children
        category_dict[parent_code] = parent_category
    end

    return
end

-- 数据库字段： value | name | icon | url
function get_sidebar_footer(row)
    local code = row.properties.value.rich_text[1].plain_text
    local name = row.properties.name.title[1].plain_text
    local url = row.properties.url.url
    local icon_rich_text = row.properties.icon.rich_text
    local icon = icon_rich_text[1] and icon_rich_text[1].plain_text or ngx.null

    return {
        code = code,
        name = name,
        icon = icon,
        url = url
    }
end

-- 数据库字段： value | name | category | icon | url | description
function get_link(links_dict, row)
    local code = row.properties.value.rich_text[1].plain_text
    local name = row.properties.name.title[1].plain_text
    local category = row.properties.category.select.name
    local url = row.properties.url.url
    local icon_rich_text = row.properties.icon.rich_text
    local icon = icon_rich_text[1] and icon_rich_text[1].plain_text or ngx.null
    local description_rich_text = row.properties.description.rich_text
    local description = description_rich_text[1] and description_rich_text[1].plain_text or ngx.null

    local links = links_dict[category] or {}
    table.insert(links, {
        code = code,
        name = name,
        category = category,
        icon = icon,
        url = url,
        description = description
    })
    links_dict[category] = links

    return
end

-- 数据库字段： value | name | url | description
function get_friend(friends, row)
    local code = row.properties.value.rich_text[1].plain_text
    local name = row.properties.name.title[1].plain_text
    local url = row.properties.url.url
    local description_rich_text = row.properties.description.rich_text
    local description = description_rich_text[1] and description_rich_text[1].plain_text or ngx.null

    table.insert(friends, {
        code = code,
        name = name,
        url = url,
        description = description
    })

    return
end

function sortFunction(a, b)
    return a.code < b.code
end

return _M
