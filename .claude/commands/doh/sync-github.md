# /doh:sync-github - Synchronisation GitHub Issues ↔ DOH Tasks

## Description

Synchronisation bidirectionnelle entre les issues GitHub et les tâches DOH. Implémente le dual ID system (!123 → #456)
avec gestion intelligente des conflicts.

## Usage

```bash
/doh:sync-github                    # Sync bidirectionnel complete
/doh:sync-github --pull             # Import issues GitHub → DOH
/doh:sync-github --push             # Export tâches DOH → GitHub
/doh:sync-github --dry-run          # Preview des changements
/doh:sync-github --force            # Force sync (ignore conflicts)
```

## Prérequis

- Repository Git avec remote GitHub configuré
- Token GitHub avec permissions issues (GITHUB_TOKEN env var)
- Index.json avec configuration github_repo

## Fonctionnalités

### 1. Détection Automatique Configuration

```bash
# Auto-détection repository GitHub
git remote get-url origin → github.com/user/repo
→ Configuration automatique dans index.json metadata.github_repo
```

### 2. Dual ID System Management

#### Mapping Local → Remote

```bash
# États des items DOH
!123 (Local only)     → Peut être pushé vers GitHub
!123→#456 (Synced)    → Mappé à GitHub issue #456
!123*→#456 (Dirty)    → Local modifié depuis sync
#456 (Remote only)    → Issue GitHub importée
```

#### Headers MD Automatiques

```bash
# Génération automatique URLs GitHub
# Task !123→#456: Titre tâche
**Status**: Synced
**Created**: 2024-08-27T10:00:00Z
**Last Sync**: 2024-08-27T14:30:00Z
**GitHub Issue**: https://github.com/user/repo/issues/456
```

### 3. Synchronisation Pull (GitHub → DOH)

#### Import Nouvelles Issues

```bash
# Scan toutes les issues GitHub ouvertes
GET /repos/{owner}/{repo}/issues
→ Filtrer issues non-mappées dans index.json
→ Créer nouveaux items DOH avec ID remote-only (#456)
```

#### Détection Modifications Remote

```bash
# Compare last_sync vs updated_at GitHub
GitHub issue.updated_at > item.synced
→ Marque item comme ayant conflict potential
→ Propose résolution ou merge automatique
```

#### Création Fichiers MD

```bash
# Pour chaque nouvelle issue GitHub
/epics/maintenance-general/task{next_id}.md
→ Parse GitHub issue body/title
→ Génère task DOH formatée
→ Update index.json avec mapping #456 → !{next_id}
```

### 4. Synchronisation Push (DOH → GitHub)

#### Export Nouvelles Tâches

```bash
# Items !123 (Local only)
POST /repos/{owner}/{repo}/issues
{
  "title": "Task !123: {title}",
  "body": "{formatted_task_content}",
  "labels": ["doh-task", "auto-generated"]
}
→ Récupère nouveau issue number #456
→ Update item: !123 → !123→#456 (synced)
```

#### Mise à Jour Issues Existantes

```bash
# Items !123*→#456 (Dirty)
PATCH /repos/{owner}/{repo}/issues/{issue_number}
{
  "title": "Task !123: {updated_title}",
  "body": "{updated_content}",
  "state": "{open|closed}"
}
→ Update timestamps: synced = now, dirty = null
```

### 5. Gestion des Conflicts

#### Détection Conflicts

```bash
# Conflict = modifications simultanées remote ET local
item.dirty > item.synced AND github.updated_at > item.synced
→ État conflict détecté
```

#### Résolution Interactive

```bash
🚨 CONFLICT détecté sur Task !123→#456:

Local (modifié 2024-08-27 15:00):  "Implémenter WebSocket handler"
GitHub (modifié 2024-08-27 15:30): "Implement WebSocket handler with auth"

Options:
[1] Garder version locale (écrase GitHub)
[2] Prendre version GitHub (écrase local)
[3] Merge manuel (ouvre éditeur)
[4] Skip ce conflict

Choix (1-4):
```

#### Auto-Resolution Rules

```bash
# Résolution automatique quand possible
- Seul le title modifié → Merge automatique
- Seule description modifiée → Update description
- Status change seulement → Sync status
- Labels/assignees → Merge non-conflictuel
```

### 6. Format de Synchronisation

#### DOH Task → GitHub Issue

```bash
# Transformation automatique
Title: "Task !123: {doh_title}"
Body:
"""
## Description DOH
{task_description}

## Implementation Details
{technical_sections}

---
*Synchronisé depuis DOH Task !123*
*Last sync: 2024-08-27T14:30:00Z*
"""

Labels: ["doh-task", "epic-1", "priority-medium"]
```

#### GitHub Issue → DOH Task

```bash
# Parsing et normalisation
GitHub Title: "Fix responsive menu bug"
→ DOH Title: "Fix responsive menu bug"

GitHub Body: "{issue_description}"
→ DOH Description: Reformaté avec sections standard

GitHub Labels: ["bug", "frontend"]
→ DOH Categories: Auto-assignment Epic #0 (🐛 Bug Fixes)
```

### 7. Batch Operations

#### Sync Multiple Items

```bash
# Sync sélectif par epic
/doh:sync-github --epic=1    # Sync seulement epic !1
/doh:sync-github --tasks="123,124,125"  # Sync tâches spécifiques
/doh:sync-github --since="2024-08-27"   # Sync modifs depuis date
```

#### Bulk Import

```bash
# Import massif issues GitHub
/doh:sync-github --import-all
→ Importe toutes issues ouvertes non-mappées
→ Auto-assignment Epic #0 avec catégorisation
→ Préserve meta GitHub (assignees, labels, etc.)
```

## Interface & Reporting

### Sync Status Display

```bash
/doh:sync-github --status

📊 DOH ↔ GitHub Sync Status

🔄 Configuration:
  Repository: github.com/myproject/project
  Last sync: 2024-08-27T14:30:00Z
  Token: ✅ Valid (expires 2024-12-31)

📈 Statistics:
  Total DOH items: 15
  Synced items (!123→#456): 8
  Local only (!123): 3
  Remote only (#456): 2
  Conflicts: 1
  Dirty items: 1

⚠️  Issues requiring attention:
  - Task !125*→#789: Modified both sides (CONFLICT)
  - Task !126: Local only, ready for push
  - Issue #790: GitHub only, not imported

🔧 Next steps:
  1. Resolve conflict !125→#789
  2. Push local task !126
  3. Import GitHub issue #790
```

### Sync Execution Report

```bash
🚀 GitHub Sync Complete!

📤 PUSHED (DOH → GitHub):
  ✅ Task !126 → Created issue #791 "Optimize image loading"
  ✅ Task !127*→#788 → Updated issue #788 "Fix auth bug"

📥 PULLED (GitHub → DOH):
  ✅ Issue #792 → Created task !128 "Update dependencies"
  ✅ Issue #788 → Updated task !127 (merged changes)

⚠️  CONFLICTS (manual resolution required):
  🚨 Task !125*→#789: Title differs, opened editor

📊 Summary:
  - Items synced: 4
  - New mappings: 2
  - Conflicts resolved: 0 (1 pending)
  - Errors: 0

⏰ Sync duration: 1.2s
```

## Configuration & Security

### GitHub Token Setup

```bash
# Configuration token GitHub
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# Ou dans .env project
GITHUB_TOKEN=ghp_xxxxxxxxxxxx

# Permissions requises
- repo:read (lecture repository)
- issues:write (création/modification issues)
- metadata:read (accès métadonnées repository)
```

### Repository Configuration

```bash
# Configuration automatique dans index.json
{
  "metadata": {
    "github_repo": "myproject/project",
    "github_api_base": "https://api.github.com",
    "sync_enabled": true,
    "auto_sync_interval": null,
    "sync_labels": ["doh-task", "auto-sync"]
  }
}
```

### Mapping Persistence

```bash
# Sauvegarde relations dans index.json
{
  "items": {
    "!123": {
      "remote_id": "#456",
      "remote_url": "https://github.com/user/repo/issues/456",
      "synced": "2024-08-27T14:30:00Z",
      "dirty": null
    }
  },
  "sync_status": {
    "last_github_sync": "2024-08-27T14:30:00Z",
    "pending_sync_items": ["!126"],
    "conflict_items": ["!125"]
  }
}
```

## Error Handling & Robustness

### API Rate Limits

```bash
# GitHub rate limit: 5000 req/hour
→ Batch requests quand possible
→ Respect headers X-RateLimit-*
→ Exponential backoff si rate limited
→ Cache API responses localement
```

### Network Failures

```bash
# Gestion failures réseau
→ Retry automatique avec exponential backoff
→ Partial sync en cas d'interruption
→ Recovery depuis dernière sync réussie
→ Rollback en cas d'échec critique
```

### Data Integrity

```bash
# Protection données
→ Backup index.json avant sync majeure
→ Validation JSON schema après modifications
→ Vérification cohérence mappings
→ Détection corruptions et auto-repair
```

## Examples Pratiques

### Workflow Collaboratif

```bash
# Dev A crée tâche locale
/doh:quick "corriger bug mobile"  → Task !130

# Push vers GitHub pour collaboration
/doh:sync-github --push          → Issue #800 créée

# Dev B modifie issue #800 sur GitHub
→ Ajoute assignee, labels, commentaires

# Dev A sync pour récupérer modifications
/doh:sync-github --pull          → Task !130→#800 updated
```

### Import Project Existent

```bash
# Project avec issues GitHub existantes
/doh:sync-github --import-all
→ Import 47 issues → 47 tasks DOH
→ Auto-assignment Epic #0 avec catégorisation
→ Préserve historical data GitHub
```

### Résolution Conflict Complexe

```bash
# Conflict sur description technique
Task !125: Description détaillée côté DOH
Issue #789: Précisions ajoutées côté GitHub

/doh:sync-github  → Détection conflict
→ Ouvre éditeur merge 3-way
→ Résolution manuelle + validation
→ Sync final avec résolution
```

---

_Synchronisation GitHub/GitLab - Traceabilité complète project ↔ issues_
