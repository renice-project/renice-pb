# AGENTS.md · renice-pb

> 状态：现行。这份是给在本仓库干活的 agent 和人看的规矩。

renice-pb 存放 renice 系列服务之间 gRPC 通信的**契约**：`.proto` 文件，以及由它生成、一起提交的 Go 代码。服务只通过 `go get github.com/renice-project/renice-pb` 引用这里，不在各自仓库里复制 proto。

## 1. 硬规则

1. **proto 是唯一事实来源。** 先改 proto，再跑 `scripts/gen.sh`，`gen/` 里的代码一律不手改（文件头写着 `DO NOT EDIT`）。
2. **每个 service、rpc、message、field、enum 都要有注释**，而且字段注释末尾要带一个业务例子（`例：...`）。`buf lint` 的 `COMMENTS` 规则会拦缺注释的，"带例子"靠 review。
   - 为什么：读接口的人多半没见过这个业务，一个例子比三行定义好懂。
3. **同一个版本里只做向后兼容的加法**：加字段、加 rpc、加 message 可以。删字段、改字段编号、改类型、改语义一律不行，要开新版本目录（见第 3 节）。CI 的 `buf breaking` 会拦。
4. **字段编号永不复用。** 确实要废弃一个字段时，用 `reserved` 把编号和名字都占住。
5. 提交、打 tag、推送都只在用户要求时做。

## 2. 目录

```
renice-pb/
├── proto/renice/<服务>/v<N>/*.proto   # 包名 renice.<服务>.v<N>，目录和包名必须一致
├── gen/go/renice/<服务>/v<N>/         # 生成的 Go 代码（包名 <服务>v<N>，如 ssov1）
├── buf.yaml                           # lint 与 breaking 规则
├── buf.gen.yaml                       # 生成规则（go_package 由 managed mode 统一加前缀）
├── scripts/gen.sh                     # 格式化 + lint + 生成 + 编译，一条命令
└── .github/workflows/ci.yml           # 格式、lint、breaking、生成一致性、编译
```

## 3. 版本

- 包名里的 `v1`、`v2` 是**接口版本**，只在有破坏性改动时升：新建 `proto/renice/<服务>/v2/`，v1 原样保留，两个版本并存，直到所有调用方迁完再删 v1。
- 仓库的 git tag（`v0.1.0` …）是**发布版本**，用 semver：加了新接口升 MINOR，只改注释或修生成问题升 PATCH。各服务在 `go.mod` 里钉这个 tag。
- 一个 tag 可以同时包含 `sso/v1` 和 `sso/v2`，两套版本不冲突。

## 4. 改一个接口的步骤

1. 改或新增 `proto/renice/<服务>/v<N>/*.proto`，每个新字段写注释和例子。
2. 运行 `scripts/gen.sh`，预期最后一行输出 `生成完成`。
3. `git diff` 看一遍 proto 和生成的代码。
4. 在 `CHANGELOG.md` 的「未发布」下写一行。
5. 用户要求提交时再提交；发布时由用户决定打哪个 tag。
6. 回到调用方和被调方仓库：`go get github.com/renice-project/renice-pb@<tag>`。

## 5. 命名约定

| 东西 | 规则 | 例子 |
|---|---|---|
| 包 | `renice.<服务>.v<N>` | `renice.sso.v1` |
| service | `<名词>Service` | `SSOService` |
| rpc | 动词开头 | `ExchangeCode`、`GetUser`、`ListUsers` |
| 入参 / 出参 | `<Rpc>Request` / `<Rpc>Response`，每个 rpc 独占一对 | `ExchangeCodeRequest` |
| 字段 | `snake_case` | `display_name` |
| 时间 | `google.protobuf.Timestamp` | `created_at` |
| 金额 | `string`，十进制字符串，注释写单位 | `"12.50"`（元） |
| ID | `int64` | `id` |

## 6. 错误码

rpc 用标准 gRPC 状态码，错误信息写给人看、用中文，说清哪里不对：

| 情况 | 状态码 |
|---|---|
| 入参不合法、code 过期 | `INVALID_ARGUMENT` |
| 调用方身份不对 | `UNAUTHENTICATED` |
| 有身份但没权限 | `PERMISSION_DENIED` |
| 找不到 | `NOT_FOUND` |
| 冲突（重复创建等） | `ALREADY_EXISTS` |
| 服务端自己出错 | `INTERNAL` |
| 下游暂时不可用 | `UNAVAILABLE` |

## 7. 门禁

提交前本地跑一遍，全部通过才提交：

```bash
scripts/gen.sh            # 预期最后一行：生成完成
buf breaking --against '.git#branch=main'   # 在分支上开发时对比 main，预期无输出
git status --short gen/   # 预期：只有你改的 proto 对应的文件
```
