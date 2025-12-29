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

### Security
- Encryption at rest using customer-managed KMS keys
- Principle of least privilege IAM role configuration
- Secure credential provider configurations