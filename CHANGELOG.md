# CHANGELOG

> 状态：只追加。每次发布写一节：新增 / 变更 / 移除，加一两句背景。

## 未发布

### 新增

- `renice.sso.v1.SSOService.ExchangeCode`：用一次性 code 换用户身份。背景：各服务自己签发 AT/RT，SSO 只负责确认"这个人是谁"，所以对内只需要这一个接口（2026-10-28 定）。
- buf lint（`STANDARD` + `COMMENTS`）、buf breaking（`FILE`）与 CI。
