# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
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

### Changed
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