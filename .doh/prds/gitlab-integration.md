---
created: 2025-09-05T17:21:14+02:00
file_version: 0.2.0
updated: "2025-09-05T17:21:14+02:00"
number: "050"
name: gitlab-integration
status: backlog
description: Add GitLab support with provider plugin architecture for VCS abstraction
target_version: 2.0.0
---


# PRD: gitlab-integration

## Executive Summary
Add GitLab support with provider plugin architecture for VCS abstraction

## Problem Statement
DOH currently only supports GitHub as its Version Control System (VCS) integration, limiting adoption by teams using GitLab or other platforms. The tight coupling to GitHub's API prevents teams from leveraging DOH's powerful task and epic management capabilities when using alternative VCS providers.

## User Stories
- As a GitLab user, I want to use DOH with my GitLab projects so I can manage epics and tasks without switching to GitHub
- As a DevOps engineer, I want to configure DOH to work with our self-hosted GitLab instance
- As a team lead, I want the same DOH functionality regardless of whether we use GitHub or GitLab
- As a developer, I want to sync issues, create merge requests, and update statuses in GitLab just like with GitHub

## Requirements

### Functional Requirements
- **GitLab API Integration**: Full support for GitLab API matching current GitHub functionality
  - Issue synchronization (create, update, close)
  - Merge Request creation and management (equivalent to GitHub PRs)
  - Status updates and progress tracking
  - Label and milestone management
  - Comment synchronization
- **Provider Plugin Architecture**: Extensible system for VCS providers
  - Abstract interface defining required VCS operations
  - Plugin loading mechanism
  - Provider-agnostic command layer
- **Configuration System**: Provider selection and settings in `.doh/config`
  - Provider selection (github, gitlab, future providers)
  - Authentication configuration (tokens, URLs)
  - Provider-specific settings (API endpoints for self-hosted)
- **Feature Parity**: All current GitHub features must work with GitLab
  - `/doh:sync` commands
  - `/doh:issue-*` commands
  - `/doh:epic-sync` functionality
  - Status and progress reporting

### Non-Functional Requirements
- **Performance**: GitLab operations should perform similarly to GitHub operations
- **Security**: Secure token storage and API communication
- **Compatibility**: Support GitLab.com and self-hosted GitLab instances (v14.0+)
- **Extensibility**: Architecture must allow easy addition of new providers
- **Backward Compatibility**: Existing GitHub-based projects must continue working

## Success Criteria
- All existing DOH commands work identically with GitLab as they do with GitHub
- Clean plugin architecture demonstrated by having two working providers
- Zero regression in GitHub functionality
- Configuration allows seamless switching between providers
- Documentation covers both GitHub and GitLab usage

## Constraints & Assumptions
- Must maintain backward compatibility with existing GitHub integration
- Configuration changes may require migration for existing projects
- Assumes GitLab API v4 compatibility
- Initial implementation focuses on GitLab.com and modern self-hosted versions

## Out of Scope
- Support for other VCS providers (Bitbucket, Gitea) in this PRD
- Migration tools between GitHub and GitLab projects
- Cross-provider synchronization
- GitLab-specific features not present in GitHub

## Dependencies
- No external dependencies for core functionality
- Existing DOH architecture must support provider abstraction
- Configuration system needs enhancement to support provider settings
