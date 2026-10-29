# CHANGELOG

> 状态：只追加。每次发布写一节：新增 / 变更 / 移除，加一两句背景。

## 未发布

## 0.1.0 — 2026-10-29

第一个发布版本，renice-sso v0.1.0 和接入它的服务都钉这个 tag。

### 新增

- `renice.sso.v1.SSOService.ExchangeCode`：用一次性 code 换用户身份。背景：各服务自己签发 AT/RT，SSO 只负责确认"这个人是谁"，所以对内只需要这一个接口（2026-10-28 定）。
- buf lint（`STANDARD` + `COMMENTS`）、buf breaking（`FILE`）与 CI。
- `ExchangeCode` 的注释写全处理顺序和错误码：secret 先于 code 校验（secret 错不消耗 code）、用户停用返回 PERMISSION_DENIED；例子里的域名从 sso.renice.cc 改成 renice.cc（SSO 部署在根域名，2026-10-29 定）。
