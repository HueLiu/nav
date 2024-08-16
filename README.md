# 一个基于 [Notion](https://www.notion.so) + [OpenResty](https://openresty.org) 的伪静态响应式网址导航主题

## 使用说明

这是一个完全开源的项目，你可以直接拿来制作自己的网址导航，如果你对本主题进行了一些个性化调整，欢迎来本项目中 [issue](https://github.com/HueLiu/nav/issues) 分享一下！

- 复制 [Notion 模板](https://ambitious-iodine-152.notion.site/5161a09e2e5b421590a4278155ba4e44?v=a16988cd530d4a819493556ecc6c5f62&pvs=4) 并获取你的 Notion 模板 ID
  - 创建 [Notion API token](https://www.notion.so/profile/integrations)，
  - 将你的 Notion 模板连接到该 token
- 安装 [OpenResty](https://openresty.org) 到本地或服务器

  - 设置环境变量

    ``` .env
    SITE_TYPE=notion
    NOTION_DATABASE=你的 Notion 模板 ID
    NOTION_TOKEN=你的 Notion API Token
    ```

- 克隆本项目到本地或服务器，在项目根目录下执行命令（你也可以调整nginx配置文件）:

  ```shell
  启动：openresty -p `pwd`/ -c conf/nginx.conf
  停止：openresty -p `pwd`/ -c conf/nginx.conf -s stop # 立即关闭整个服务
  退出 -p `pwd`/ -c conf/nginx.conf -s quit # “优雅” 的关闭整个服务，worker 进程处理完当前用户请求再关闭
  重启：openresty -p `pwd`/ -c conf/nginx.conf -s reload # 重读配置文件并使用服务对新配置项生效，只针对配置文件
  ```

## 计划

- [ ] docker
- [ ] 集成 AriaTable
- [ ] 集成 NocoDB

## 感谢

本项目的部分代码参考了以下开源项目，特此感谢。

- [shenweiyan/WebStack-Hugo](https://github.com/shenweiyan/WebStack-Hugo)
