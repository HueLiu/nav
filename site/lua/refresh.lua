-- 共享变量值获取
local shared_data = ngx.shared.shared_data
local uri = ngx.var.request_uri

local type = shared_data:get("site_type")
if type == "notion" then
    local database_id = shared_data:get("notion_database")
    if uri == "/refresh/" .. database_id then
      shared_data:delete("site_data")
      local site = require("lib.site")
      site.get_site_data()
      ngx.redirect("/")
    else
      ngx.exec("/404")
    end
end

ngx.exec("/404")
