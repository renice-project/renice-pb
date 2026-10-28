#!/usr/bin/env bash
# 重新生成 gen/go。用法：scripts/gen.sh
# 预期输出：最后一行「生成完成」；之后 git status 里只出现你改过的 proto 对应的 .pb.go。
set -euo pipefail
cd "$(dirname "$0")/.."

# 固定版本：和 .github/workflows/ci.yml 保持一致，不一致会导致 CI 的「生成结果一致」检查失败。
BUF_VERSION=v1.75.0
PROTOC_GEN_GO_VERSION=v1.36.12
PROTOC_GEN_GO_GRPC_VERSION=v1.6.2

need() {
  local bin=$1 pkg=$2 ver=$3
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "安装 $bin@$ver"
    go install "$pkg@$ver"
  fi
}
need buf github.com/bufbuild/buf/cmd/buf "$BUF_VERSION"
need protoc-gen-go google.golang.org/protobuf/cmd/protoc-gen-go "$PROTOC_GEN_GO_VERSION"
need protoc-gen-go-grpc google.golang.org/grpc/cmd/protoc-gen-go-grpc "$PROTOC_GEN_GO_GRPC_VERSION"

buf format -w
buf lint
rm -rf gen/go
buf generate
go mod tidy
go build ./...
echo "生成完成"
