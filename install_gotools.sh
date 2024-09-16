#!/usr/bin/zsh

go install golang.org/x/tools/gopls@latest

go install github.com/google/gops@latest
go install github.com/google/go-licenses@latest

go install mvdan.cc/gofumpt@latest
go install golang.org/x/lint/golint@latest
go install github.com/hotei/deadcode@latest
go install github.com/go-critic/go-critic/cmd/gocritic@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/jstemmer/gotags@latest
go install github.com/tommy-muehle/go-mnd/v2/cmd/mnd@latest
go install github.com/securego/gosec/cmd/gosec@latest
go install filippo.io/age/cmd/...@latest
go install github.com/yagipy/maintidx/cmd/maintidx@latest

go install golang.org/x/vuln/cmd/govulncheck@latest

go install golang.org/x/perf/cmd/benchstat@latest

mkdir -p ~/go/bin

# golang staticcheck
go install honnef.co/go/tools/cmd/staticcheck@latest
go install honnef.co/go/tools/cmd/keyify@latest
go install honnef.co/go/tools/cmd/structlayout-pretty@latest
go install honnef.co/go/tools/cmd/structlayout-optimize@latest
go install honnef.co/go/tools/cmd/keyify@latest
go install honnef.co/go/tools/cmd/structlayout@latest

# more tools
# go install go.uber.org/mock/mockgen@latest
go install github.com/golang/mock@latest
go install github.com/fatih/gomodifytags@latest
go install github.com/dotzero/git-profile@latest
go install gotest.tools/gotestsum@latest
go install github.com/maaslalani/slides@latest

go install github.com/go-swagger/go-swagger/cmd/swagger@latest

go install github.com/blmayer/awslambdarpc@latest

go install github.com/xxxserxxx/gotop/v4/cmd/gotop@latest
go install github.com/jesseduffield/lazydocker@latest

# Install fixed version of linter !!
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.54.2
