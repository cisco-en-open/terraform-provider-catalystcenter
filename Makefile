TEST?=$$(go list ./... | grep -v 'vendor')
HOSTNAME=hashicorp.com
NAMESPACE=edu
NAME=catalystcenter
BINARY=terraform-provider-${NAME}
VERSION=1.2.0-beta
OS_ARCH=darwin_arm64
# Change to OS_ARCH=darwin_arm64 or your current architecture
GOFMT_FILES?=$$(find . -name '*.go' |grep -v vendor)
WEBSITE_REPO=github.com/hashicorp/terraform-website


default: install

build: fmtcheck
	go build -o ${BINARY}_${VERSION}_${OS_ARCH}

release:
	GOOS=darwin GOARCH=amd64 go build -o ./bin/${BINARY}_${VERSION}_darwin_amd64
	GOOS=freebsd GOARCH=386 go build -o ./bin/${BINARY}_${VERSION}_freebsd_386
	GOOS=freebsd GOARCH=amd64 go build -o ./bin/${BINARY}_${VERSION}_freebsd_amd64
	GOOS=freebsd GOARCH=arm go build -o ./bin/${BINARY}_${VERSION}_freebsd_arm
	GOOS=linux GOARCH=386 go build -o ./bin/${BINARY}_${VERSION}_linux_386
	GOOS=linux GOARCH=amd64 go build -o ./bin/${BINARY}_${VERSION}_linux_amd64
	GOOS=linux GOARCH=arm go build -o ./bin/${BINARY}_${VERSION}_linux_arm
	GOOS=openbsd GOARCH=386 go build -o ./bin/${BINARY}_${VERSION}_openbsd_386
	GOOS=openbsd GOARCH=amd64 go build -o ./bin/${BINARY}_${VERSION}_openbsd_amd64
	GOOS=solaris GOARCH=amd64 go build -o ./bin/${BINARY}_${VERSION}_solaris_amd64
	GOOS=windows GOARCH=386 go build -o ./bin/${BINARY}_${VERSION}_windows_386
	GOOS=windows GOARCH=amd64 go build -o ./bin/${BINARY}_${VERSION}_windows_amd64

install: build
	mkdir -p ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/${OS_ARCH}
	mv ${BINARY}_${VERSION}_${OS_ARCH} ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/${OS_ARCH}

test: fmtcheck
	go test -i $(TEST) || exit 1
	echo $(TEST) | xargs -t -n4 go test $(TESTARGS) -timeout=30s -parallel=4

testacc:
	TF_ACC=1 go test $(TEST) -v $(TESTARGS) -timeout 120m

fmt:
	gofmt -w $(GOFMT_FILES)

fmtcheck:
	scripts/gofmtcheck.sh

errcheck:
	scripts/errcheck.sh

developtest:
	mkdir -p ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/${OS_ARCH}
	cp ./bin/${BINARY}_${VERSION}_${OS_ARCH} ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/${OS_ARCH}

vet:
	@echo "go vet ."
	@go vet $$(go list ./... | grep -v vendor/) ; if [ $$? -eq 1 ]; then \
		echo ""; \
		echo "Vet found suspicious constructs. Please check the reported constructs"; \
		echo "and fix them if necessary before submitting the code for review."; \
		exit 1; \
	fi

# New testing targets for comprehensive testing
test-unit:
	@echo "Running unit tests..."
	@go test -v -run "^Test[^Acc]" ./catalystcenter/... -timeout 30s

test-integration:
	@echo "Running integration tests..."
	@go test -v -run "TestIntegration" ./catalystcenter/... -timeout 60s

test-coverage:
	@echo "Generating coverage report..."
	@go test -coverprofile=coverage.out ./catalystcenter/...
	@go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

test-coverage-report:
	@echo "Coverage summary:"
	@go test -cover ./catalystcenter/... | grep -E "coverage:|ok"

test-benchmark:
	@echo "Running benchmark tests..."
	@go test -bench=. -benchmem -run=^$$ ./catalystcenter/...

test-race:
	@echo "Running tests with race detector..."
	@go test -race ./catalystcenter/...

test-all: test-unit test-coverage-report

test-verbose:
	@echo "Running all tests with verbose output..."
	@go test -v ./catalystcenter/...

test-specific:
	@echo "Running specific test: $(TEST_NAME)"
	@go test -v -run $(TEST_NAME) ./catalystcenter/...

test-clean:
	@echo "Cleaning test artifacts..."
	@rm -f coverage.out coverage.html
	@rm -f test_report_*.txt
	@rm -f benchmark_results.txt

.PHONY: test test-unit test-integration test-coverage test-coverage-report test-benchmark test-race test-all test-verbose test-specific test-clean testacc
