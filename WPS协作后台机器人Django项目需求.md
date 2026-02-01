# WPS 开发平台webhook机器人文档
https://365.kdocs.cn/3rd/open/documents/app-integration-dev/guide/robot/webhook

---

# Django项目需求

* 支持接收机器人webhook回调地址的post请求，并解析数据
* 支持向机器人的webhook地址post消息
* 支持添加hook脚本处理webhook回调接收到的消息
* 提供web控制台页面，支持向机器人发送和查看接收到的消息的UI界面，以及配置机器人webhook地址
* 项目配置文件支持设置默认web控制台管理员用户名和密码
* web控制台页面需要账号密码登录才能使用
* 每个账号支持配置多个机器人，并且为每个机器人定义名称
* 机器人webhook回调地址，格式为：域名/at_robot/用户名/机器人名称
* 管理员账号可以在web控制台页面新增、删除用户，以及修改用户密码
* hook脚本支持上传python脚本文件
* 数据库默认只记录每个机器人的最近100条信息，并且支持设置最多保存多少条记录(设置上限值1000)
* 改用8080和443端口
* 支持发送卡片类型消息

# 需求变更：
* v4.0 (2026-01-30): 机器人webhook回调地址格式改为：域名/at_robot/用户名/机器人名称
