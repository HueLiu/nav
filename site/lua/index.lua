-- 共享变量值获取
local shared_data = ngx.shared.shared_data
local template_caching = shared_data:get("template_caching")

local template = require("resty.template")
-- 是否缓存解析后的模板，默认true
template.caching(template_caching)

local site = require("lib.site")
local data = site.get_site_data()
data.hitokoto = site.get_hitokoto()

template.render("index.html", data)
