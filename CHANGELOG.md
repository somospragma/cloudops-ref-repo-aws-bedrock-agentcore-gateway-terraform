# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Support for associating an AWS WAFv2 Web ACL to a gateway through the optional `web_acl` object (`web_acl = { arn = "..." }`) in each `gateways` entry. Creates an `aws_wafv2_web_acl_association` using the gateway ARN as `resource_arn`. The Web ACL must be REGIONAL and in the same region as the gateway; it is managed outside the module. One gateway supports at most one Web ACL. It is an object (not a plain string) on purpose: the module filters gateways by the presence of the object, which is known at plan time even when the ARN is computed during apply (for example, a Web ACL created in the same run). Filtering by an unknown string ARN would make the `for_each` keys unknown.
- Validation: `web_acl.arn` must be a REGIONAL WAFv2 Web ACL ARN.
- Support for a per-gateway KMS key through `kms_key_arn` in each `gateways` entry (applied when `enable_encryption = true`). It takes precedence over the global `kms_key_arn` variable.
- New output `web_acl_associations` (map of Web ACL ARN by gateway key).
- Note: the WAF failure mode (`FAIL_CLOSE`/`FAIL_OPEN`, `wafConfiguration` in the AWS API) is not exposed by the AWS provider yet, so the AWS default (`FAIL_CLOSE`) applies.
- Initial release of Amazon Bedrock AgentCore Gateway module
- Support for JWT and IAM authorization types
- Gateway target management with Lambda, OpenAPI, and MCP server configurations
- Comprehensive security hardening following PC-IAC-020 standards
- Full compliance with PC-IAC governance rules
- Support for `allowed_scopes` in JWT authorizer configuration
- Support for `custom_claims` in JWT authorizer configuration with validation of:
  - Claim value types: `STRING`, `STRING_ARRAY`
  - Match operators: `EQUALS`, `CONTAINS`, `CONTAINS_ANY`
  - Match values: `match_value_string` for single values, `match_value_string_list` for arrays
- Support for `grant_type` in OAuth credential provider configuration (`CLIENT_CREDENTIALS`, `AUTHORIZATION_CODE`, `TOKEN_EXCHANGE`)
- Support for `default_return_url` in OAuth credential provider (required for `AUTHORIZATION_CODE` grant type)
- Support for `listing_mode` in MCP server targets (`DEFAULT` or `DYNAMIC`). DEFAULT caches capabilities for semantic search; DYNAMIC forwards list calls live to the MCP server for per-user tool discovery
- Validation: `listing_mode = "DYNAMIC"` is incompatible with `search_type = "SEMANTIC"` at the gateway level
- Support for `session_configuration` in `protocol_config` (with `session_timeout_in_seconds`, range 900–28800, default 3600) to enable MCP sessions. When enabled, the gateway generates and returns the `Mcp-Session-Id` response header on the first `initialize`
- Support for `streaming_configuration` in `protocol_config` (with `enable_response_streaming`), a prerequisite for elicitation/sampling
- Validation: `session_timeout_in_seconds` must be between 900 and 28800 when `session_configuration` is set
- Validation: `Mcp-Session-Id` is not allowed in a target's `metadata_configuration` (`allowed_request_headers`/`allowed_response_headers`) when the gateway has sessions enabled, avoiding HTTP 400 Bad Request

### Changed
- The global `kms_key_arn` variable is deprecated in favor of `kms_key_arn` inside each `gateways` entry. It still works as a default for gateways that do not define their own key.
- Minimum AWS provider version raised from `>= 4.31.0` to `>= 6.50.0`. `aws_bedrockagentcore_gateway*` resources exist since 6.17.0, and the module uses `session_configuration`/`streaming_configuration` (6.49.0) and `listing_mode` (6.50.0).
- `search_type` in `protocol_config` no longer defaults to `"SEMANTIC"`. It must be explicitly set to enable semantic search. This enables gateways with DYNAMIC targets to be created without conflicts. Existing configurations that explicitly set `search_type = "SEMANTIC"` are unaffected.
- `exception_level` no longer defaults to `"DEBUG"`. The only valid value is `"DEBUG"` (to enable verbose error messages) or `null` (omitted, for sanitized messages in production). Invalid values like `"ERROR"` or `"WARN"` are now caught by validation.

### Documentation
- Added migration guide for transitioning from `listing_mode = "DYNAMIC"` to `"DEFAULT"` with semantic search enabled. The AWS API does not allow enabling `search_type = "SEMANTIC"` on a gateway with existing targets — a 3-step apply process is required.

### Fixed
- Fix "Provider produced inconsistent result after apply" error on `credential_provider_configuration.oauth.grant_type` when using AWS provider >= 6.48.0. The field is now explicitly set (defaults to `CLIENT_CREDENTIALS`) to prevent drift between plan and apply.

### Security
- Encryption at rest using customer-managed KMS keys
- Principle of least privilege IAM role configuration
- Secure credential provider configurations