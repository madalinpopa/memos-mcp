
.DEFAULT_GOAL := test

.PHONY: init
init:
	go mod download
	direnv allow .

.PHONY: secrets
secrets:
	op inject -f -i envrc.template -o .envrc
	direnv allow .

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Run GO commands
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
.PHONY: build
build:
	go build -o bin/server .

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Run development commands
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# run air to detect any go file changes to re-build and re-run the server.
.PHONY: dev
dev:
	go tool air \
	--build.cmd "go build -o ./tmp/bin/server ." --build.bin "tmp/bin/server" --build.delay "100" \
	--build.include_ext "go" \
	--build.stop_on_error "false" \
	--misc.clean_on_exit true

inspect:
	npx @modelcontextprotocol/inspector

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Run test commands
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# run go tests
.PHONY: test
test:
	go test ./... | less

# check for data race conditions
.PHONY: race
race:
	go test -race ./... | less

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Run release commands
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
.PHONY: release/patch
release/patch:
		@if [ $$(git tag | wc -l) -eq 0 ]; then \
    		NEW_TAG="v0.0.1"; \
    	else \
    		LATEST_TAG=$$(git describe --tags `git rev-list --tags --max-count=1`); \
    		MAJOR=$$(echo $$LATEST_TAG | cut -d. -f1 | tr -d 'v'); \
    		MINOR=$$(echo $$LATEST_TAG | cut -d. -f2); \
    		PATCH=$$(echo $$LATEST_TAG | cut -d. -f3); \
    		NEW_PATCH=$$((PATCH + 1)); \
    		NEW_TAG="v$$MAJOR.$$MINOR.$$NEW_PATCH"; \
    	fi; \
    	git tag -a $$NEW_TAG -m "Release $$NEW_TAG" && \
    	echo "Created new tag: $$NEW_TAG"


.PHONY: release/minor
release/minor:
		@if [ $$(git tag | wc -l) -eq 0 ]; then \
    		NEW_TAG="v0.1.0"; \
    	else \
    		LATEST_TAG=$$(git describe --tags `git rev-list --tags --max-count=1`); \
    		MAJOR=$$(echo $$LATEST_TAG | cut -d. -f1 | tr -d 'v'); \
    		MINOR=$$(echo $$LATEST_TAG | cut -d. -f2); \
    		NEW_MINOR=$$((MINOR + 1)); \
    		NEW_TAG="v$$MAJOR.$$NEW_MINOR.0"; \
    	fi; \
    	git tag -a $$NEW_TAG -m "Release $$NEW_TAG" && \
    	echo "Created new tag: $$NEW_TAG"

.PHONY: release/major
release/major:
		@if [ $$(git tag | wc -l) -eq 0 ]; then \
    		NEW_TAG="v1.0.0"; \
    	else \
    		LATEST_TAG=$$(git describe --tags `git rev-list --tags --max-count=1`); \
    		MAJOR=$$(echo $$LATEST_TAG | cut -d. -f1 | tr -d 'v'); \
    		NEW_MAJOR=$$((MAJOR + 1)); \
    		NEW_TAG="v$$NEW_MAJOR.0.0"; \
    	fi; \
    	git tag -a $$NEW_TAG -m "Release $$NEW_TAG" && \
    	echo "Created new tag: $$NEW_TAG"
