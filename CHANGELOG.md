# CHANGELOG

> 状态：只追加。从 2026-10-30 起仓库不再打 tag（见 AGENTS.md 第 3 节），按日期记录合进 main 的改动。

## 未发布

- 为判题契约中 33 个嵌套消息及枚举字段补齐业务例子，并明确可缺省字段的省略场景。

- 明确租约到期硬边界与锁内实时时钟，首次回报和续约不等待后台回收；同身份的已完成回报优先返回幂等结果，取消优先返回停止信号。

- 修复判题机会话隔离：Hello 新增启动实例和会话代次，旧会话调用及延迟长轮询先拒绝；同次登记和领任务响应丢失重试保持幂等。

- 新增 `renice.judge.v1.JudgeService`：renice-oj 服务端给判题机（renice-judge 的 judgehost）用的拉模型接口。Hello（登记机器和槽位、自检）、Heartbeat（整机心跳 + 声明式预热 pin_set）、ClaimTask（长轮询领一个测试点）、RenewLease / ReportResult（fencing token 租约，回报幂等）、FetchBlob（按 sha256 流式拉文件）。背景：判题机不碰 renice-oj 的数据库，只认这份契约（ADR：renice-oj 0002）。

## 2026-10-30

- 新增 `renice.infra.v1.AgentService.Connect`：renice-infra（服务治理平台）的 agent 主动连服务端的双向流，握手（Hello / Welcome）、每 3 秒一次的主机与容器上报（Report / ReportAck，断线补传按 boot_id + seq 去重）、容器事件和主机静态信息。背景：agent 只出不进，命令以后也顺着这条流下发，本次只放采集需要的消息，发布、构建、探测、解析的命令在各自里程碑里加（ADR：renice-infra 0002）。
- 补充 `ContainerEvent` 的 event_seq / ContainerEventAck 确认去重语义；agent 持久化未确认队列、run_id 和序号，进程或机器重启后恢复补传，持久化状态丢失时告警并轮换 run_id；明确收到 `FAILED_PRECONDITION` 后停止自动重连。
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
