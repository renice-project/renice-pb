# renice-pb

renice 系列服务之间的 gRPC 契约：`.proto` 加上生成好的 Go 代码。

## 有什么

| 服务 | 包 | 说明 |
|---|---|---|
| renice-sso | `renice.sso.v1` | `SSOService.ExchangeCode`：各服务后端用登录回调里的一次性 code 换出用户身份 |

## 怎么用

```bash
go get github.com/renice-project/renice-pb@latest
```

```go
import ssov1 "github.com/renice-project/renice-pb/gen/go/renice/sso/v1"

conn, err := grpc.NewClient("renice-sso-server:9090",
	grpc.WithTransportCredentials(insecure.NewCredentials())) // 只在内网 docker network 里调用
if err != nil {
	return err
}
client := ssov1.NewSSOServiceClient(conn)
resp, err := client.ExchangeCode(ctx, &ssov1.ExchangeCodeRequest{
	Code:         code,
	ClientId:     "renice-oj",
	ClientSecret: cfg.SSO.ClientSecret,
	RedirectUri:  "https://oj.renice.cc/api/v1/auth/callback",
})
```

## 改接口

先读 [AGENTS.md](AGENTS.md)。一句话版本：改 proto → `scripts/gen.sh` → 提交 proto 和 `gen/`；同一个版本里只能加，不能删改。

## 本地工具

- Go 1.27+（推荐用 [g](https://github.com/voidint/g) 管理版本）
- `scripts/gen.sh` 会自动 `go install` 固定版本的 buf、protoc-gen-go、protoc-gen-go-grpc
