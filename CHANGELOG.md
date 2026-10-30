# CHANGELOG

> 状态：只追加。从 2026-10-30 起仓库不再打 tag（见 AGENTS.md 第 3 节），按日期记录合进 main 的改动。

## 2026-10-30

- 新增 `renice.infra.v1.AgentService.Connect`：renice-infra（服务治理平台）的 agent 主动连服务端的双向流，握手（Hello / Welcome）、每 3 秒一次的主机与容器上报（Report / ReportAck，断线补传按 boot_id + seq 去重）、容器事件和主机静态信息。背景：agent 只出不进，命令以后也顺着这条流下发，本次只放采集需要的消息，发布、构建、探测、解析的命令在各自里程碑里加（ADR：renice-infra 0002）。
- 不再发版本：各服务 `go get ...@main` 钉提交。`v0.1.0`、`v0.2.0` 两个 tag 保留。
- 注释：`ListGrants` 的 page_token 错误条件改成「不是规范的正整数十进制串」，和 renice-sso 的实现一致（原来写的「不是上一页返回的值」比实现严，renice-sso#19 CR 指出）。

## 未发布（已作为 v0.2.0 发布）

### 新增

- `renice.sso.v1.SSOService.GrantApp` / `RevokeApp` / `ListGrants`：自己管权限的服务（例如 renice-infra）把「谁可以使用我」推给 SSO，SSO 启动台据此给这些用户显示入口；`ListGrants` 按服务列出授权，给调用方对账，补上写失败的那几次。背景：各服务的权限由服务自己决定，SSO 只负责显示入口、不拦登录（2026-10-30 ice 定）。

### 变更

- 注释：`User.username` 改为字母开头、大小写字母 / 数字 / - / _、唯一性不区分大小写（renice-sso v0.1.0-alpha.1 起）；SSO 角色写成 sys / ops / admin / user（v0.1.0-alpha.2 起）。只改注释，不影响兼容。

## 0.1.0 — 2026-10-29

第一个发布版本，renice-sso v0.1.0 和接入它的服务都钉这个 tag。

### 新增

- `renice.sso.v1.SSOService.ExchangeCode`：用一次性 code 换用户身份。背景：各服务自己签发 AT/RT，SSO 只负责确认"这个人是谁"，所以对内只需要这一个接口（2026-10-28 定）。
- buf lint（`STANDARD` + `COMMENTS`）、buf breaking（`FILE`）与 CI。
- `ExchangeCode` 的注释写全处理顺序和错误码：secret 先于 code 校验（secret 错不消耗 code）、用户停用返回 PERMISSION_DENIED；例子里的域名从 sso.renice.cc 改成 renice.cc（SSO 部署在根域名，2026-10-29 定）。
