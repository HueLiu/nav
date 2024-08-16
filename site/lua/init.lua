-- 初始化耗时的模块
local template = require("resty.template")
local template_caching = true
template.caching(template_caching)
local cjson = require("cjson")
local http = require("resty.http")
local http = require("lib.notion")
local site = require("lib.site")
local String = require("util.string")

-- 读取环境变量放入共享全局内存
local shared_data = ngx.shared.shared_data
shared_data:set("site_type", String.get_env("SITE_TYPE", "notion"))
shared_data:set("notion_token", String.get_env("NOTION_TOKEN", "secret_yvYQ014blL4cSe55qix56uqr8ayRVXXrQ3nlYtGTULi"))
shared_data:set("notion_database", String.get_env("NOTION_DATABASE", "5161a09e2e5b421590a4278155ba4e44"))
shared_data:set("template_caching", template_caching)
