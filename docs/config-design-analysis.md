# DOH Configuration Design Analysis

**Question**: Fichier séparé `doh.ini` vs intégration dans `project-index.json`?

---

## Option 1: Fichier Séparé `doh.ini`

### Advantages ✅

- **Lisibilité**: Format INI plus human-friendly pour configuration
- **Édition manuelle**: Plus facile à éditer à la main
- **Séparation des préoccupations**: Config vs données séparées
- **Compatibilité bash**: Format INI facile à parser en bash
- **Version control friendly**: Diffs clairs sur les changements config
- **Commentaires**: Support natif des commentaires explicatifs

### Inconvénients ❌

- **Deux fichiers**: Complexité supplémentaire
- **Synchronisation**: Risque d'incohérence entre files
- **Scripts**: Deux sources de vérité à maintenir
- **Atomicité**: Pas de transaction atomique sur les deux fichiers

---

## Option 2: Intégration dans `project-index.json`

### Advantages ✅

- **Un seul fichier**: Source de vérité unique
- **Atomicité**: Toutes les modifications dans un seul fichier
- **Scripts bash**: Plus simple (un seul jq à faire)
- **Consistance**: Pas de désynchronisation possible
- **Simplicité**: Moins de fichiers à gérer

### Inconvénients ❌

- **Lisibilité JSON**: Moins human-friendly que INI
- **Gros fichier**: project-index.json peut devenir volumineux
- **Édition manuelle**: Plus difficile à éditer
- **Pas de commentaires**: JSON ne supporte pas les commentaires natifs

---

## Analyse Pratique

### Format JSON étendu dans project-index.json

```json
{
  "metadata": {
    "version": "1.0.0",
    "project_name": "MyProject",
    "created_at": "2025-08-27T00:00:00Z",
    "updated_at": "2025-08-27T00:00:00Z",
    "language": "fr",
    "sync_targets": []
  },
  "config": {
    "behavior": {
      "epic_graduation_threshold": 6,
      "auto_categorization": true,
      "strict_validation": false,
      "backup_before_changes": true
    },
    "scripting": {
      "enable_bash_optimization": true,
      "fallback_to_claude": true,
      "performance_tracking": false,
      "debug_mode": false,
      "quiet_mode": false
    },
    "templates": {
      "default_task_template": "standard",
      "default_epic_template": "standard",
      "include_github_links": true,
      "auto_generate_ids": true
    },
    "sync": {
      "github_enabled": false,
      "github_repository": "",
      "github_token_env": "GITHUB_TOKEN"
    }
  },
  "items": { ... },
  "dependency_graph": { ... }
}
```

### Accès bash simplifié

```bash
# Un seul fichier à lire
config_value=$(jq -r '.config.scripting.enable_bash_optimization' .doh/project-index.json)

# VS deux fichiers
ini_value=$(grep '^enable_bash_optimization' .doh/doh.ini | cut -d'=' -f2)
```

---

## Recommendation Finale

### **CHOIX: Intégration dans project-index.json** 🏆

**Raisons**:

1. **Un seul fichier de vérité**: Simplicité maximale pour scripts
2. **Atomicité**: Pas de problème de synchronisation
3. **Performance**: Un seul `jq` call vs parsing INI + JSON
4. **Cohérence**: Toute la configuration project centralisée
5. **Scripts bash**: Plus simple à maintenir

### **Structure JSON optimisée**

```json
{
  "metadata": {
    // Métadonnées du project (existent)
  },
  "config": {
    "project": {
      "description": "",
      "default_branch": "main",
      "created_by": ""
    },
    "behavior": {
      "epic_graduation_threshold": 6,
      "auto_categorization": true,
      "strict_validation": false
    },
    "scripting": {
      "enable_bash_optimization": true,
      "fallback_to_claude": true,
      "performance_tracking": false,
      "debug_mode": false
    },
    "templates": {
      "default_task_template": "standard",
      "default_epic_template": "standard",
      "include_github_links": true
    },
    "sync": {
      "github_enabled": false,
      "gitlab_enabled": false
    },
    "integrations": {
      "editor_command": "",
      "notification_webhook": ""
    }
  },
  "items": { ... },
  "dependency_graph": { ... }
}
```

### **Facilité d'édition**

Pour l'édition manuelle, on peut créer des helper scripts:

```bash
# Helper pour édition config
doh_config_set() {
  local key="$1" value="$2"
  jq ".config.$key = \"$value\"" .doh/project-index.json > temp && mv temp .doh/project-index.json
}

# Example
doh_config_set "scripting.debug_mode" "true"
```

---

## Conclusion

**Décision**: **project-index.json étendu** avec section `config`

**Advantages pour DOH015**:

- Scripts bash plus simples (un seul fichier)
- Pas de problème de synchronisation
- Performance optimale
- Atomicité guarantee

Le sacrifice de lisibilité INI est compensé par la simplicité opérationnelle et la robustesse.
