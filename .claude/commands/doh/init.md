# /doh:init - Système d'initialisation réentrant

## Description

Initialise ou re-initialise intelligemment le système /doh dans un projet existant. Commande réentrante qui peut être exécutée plusieurs fois sans dégâts.

## Usage

```bash
/doh:init              # Mode interactif avec questions si doute
/doh:init --force      # Force la réinitialisation (optionnel)
/doh:init --scan-only  # Scan seulement sans modifications (optionnel)
```

**Note**: En DOH, toutes les options sont optionnelles. Si il y a un doute, DOH pose des questions clarifiantes.

## Fonctionnalités

### 1. Health Check & Diagnostic

- ✅ Vérifie la présence de `.claude/doh/` (système) ET `.doh/` (projet)
- ✅ Contrôle l'intégrité de `.doh/project-index.json`
- ✅ Détecte les fichiers MD orphelins (non indexés)
- ✅ Identifie les références index sans fichiers correspondants
- ✅ Valide la cohérence hiérarchique (parents ↔ enfants)

### 2. Auto-Détection Intelligente

#### Langue du Projet

```bash
# Analyse automatique de la langue
- Commentaires dans le code (// vs /**) 
- Messages de commit Git récents
- Documentation (README.md, *.md)
- Contenu des fichiers template/config
→ Défaut détecté: français/anglais
```

#### Type de Projet

```bash
# Détection du stack technique
- package.json → Node.js/JavaScript
- composer.json → PHP/Symfony  
- requirements.txt → Python
- pom.xml → Java
- Cargo.toml → Rust
→ Configuration adaptée au framework
```

#### Git Remote & Sync

```bash
# Configuration synchronisation
- origin GitHub → Propose sync GitHub
- origin GitLab → Propose sync GitLab
- Pas de remote → Mode local uniquement
→ Configuration sync automatique
```

### 3. Scan & Réindexation

#### Scan Filesystem

```bash
# Recherche exhaustive dans .doh/
.doh/epics/**/*.md    → Détecte epics non indexés
.doh/tasks/**/*.md    → Détecte tasks orphelines  
.doh/features/**/*.md → Détecte features manquantes
.doh/prds/**/*.md     → Détecte PRDs non trackés
```

#### Réindexation Intelligente

```bash
# Parsing headers MD pour récupérer métadonnées
# Epic !45: Title...          → ID=45, type=epic
# Task !123: Description...   → ID=123, type=task
# **Parent Epic**: !45        → parent=!45
# **Status**: Active          → status=active
```

#### Résolution Hiérarchie

```bash
# Reconstruction dependency graph
- Parse parent/child relationships
- Détecte références circulaires
- Résout dépendances manquantes
- Reconstruit .doh/project-index.json complet
```

### 4. Configuration CLAUDE.md

#### Intégration Intelligente

```bash
# Niveaux d'intégration /doh
Level 0: Mention disponibilité /doh
Level 1: Commandes de base + Epic #0
Level 2: Workflow complet + tracing recommandé  
Level 3: DOH obligatoire + tracing enforced
Level 4: Enterprise compliance + reporting
```

#### Templates Adaptatifs

```bash
# Génération section CLAUDE.md selon:
- Langue détectée (français/anglais)
- Type de projet (Symfony/Node/etc.)
- Niveau /doh choisi (0-4)
- Configuration sync (GitHub/GitLab/local)
```

### 5. Migration & Upgrade

#### Ancien Format → Nouveau Format

```bash
# Migration .cache → project-index.json
- Parse ancien .cache file
- Convertit vers nouveau format unified
- Sauvegarde .cache → .cache.backup
- Génère .doh/project-index.json avec métadonnées complètes
- Migration .claude/doh/epics/* → .doh/epics/*
```

#### Version System

```bash
# Gestion versions /doh
- Détecte version actuelle dans .doh/project-index.json
- Compare avec version système disponible
- Propose upgrade si nécessaire
- Backup avant migration majeure
```

### 6. Context Setup

#### Anti-Vibe Coding

```bash
# Copie règles contexte obligatoire
.claude/doh/anti-vibe-coding.md → .claude/context/anti-vibe-coding.md
# Garantit que l'IA a toujours le contexte /doh
```

#### Templates & Schema

```bash
# Installation templates
- PRD templates (micro/standard/enterprise)
- Epic templates (simple/feature-rich)  
- Task templates (hotfix/standard/complex)
- JSON schemas pour validation
```

## Interface Interactive

### Mode Questions

```bash
/doh:init

🔍 Analyse du projet...
📁 Structure détectée: Symfony + JavaScript (Webpack Encore)
🌐 Langue détectée: Français (sur base des commentaires et commits)
📡 Git remote détecté: github.com/user/myproject

❓ Configuration /doh:
  [1] Minimal - Mention /doh disponible  
  [2] Light - Commandes de base + Epic #0
  [3] Standard - Workflow complet (RECOMMANDÉ)
  [4] Strict - DOH obligatoire + sync GitHub
  [5] Enterprise - Compliance complète

Niveau souhaité (1-5)? [3]: 

❓ Synchronisation GitHub?
  → Detected: github.com/user/myproject
  → Configurer sync bidirectionnel (y/N)? [N]: 

❓ Langue projet confirmée: Français 
  → Changer vers anglais (y/N)? [N]:

✅ Configuration:
  - Niveau: Standard (3)
  - Langue: Français  
  - Sync: Local uniquement
  - Templates: Français + Symfony
  
Continuer installation (Y/n)? [Y]:
```

### Mode Batch/Silent

```bash
/doh:init --level=3 --lang=fr --sync=none --no-interactive
→ Installation silencieuse avec paramètres prédéfinis
```

## Algorithme d'Exécution

### 1. Pre-flight Checks

```bash
✅ Vérifier que dans un projet Git
✅ Contrôler permissions filesystem  
✅ Détecter installation /doh existante
✅ Identifier conflicts potentiels
```

### 2. Analysis Phase

```bash
🔍 Scan filesystem pour /doh existant
📊 Analyse langue (comments + commits + docs)
🏗️ Détection stack technique (package.json, etc.)
🌐 Configuration Git remote
📈 Health check cohérence existante
```

### 3. Configuration Phase  

```bash
❓ Mode interactif OU paramètres CLI
⚙️ Génération config selon détection + choix
📝 Préparation templates adaptés
🔗 Configuration sync si demandé
```

### 4. Installation Phase

```bash
📁 Copie skeleton depuis .claude/doh/skel/ → .doh/
📄 Installation templates + schemas dans .claude/doh/  
📋 Personnalisation project-index.json (nom projet, dates, counters)
🔄 Migration données existantes si nécessaire
📝 Mise à jour CLAUDE.md
📋 Copie anti-vibe-coding.md → context/
```

### 5. Validation Phase

```bash
✅ Validation intégrité installation
🧪 Test loading de .doh/project-index.json
🔗 Vérification cohérence hiérarchies  
📊 Rapport final installation
```

## Gestion d'Erreurs

### Réentrance Safe

```bash
# Peut être exécuté N fois sans problème
- Backup avant modifications importantes
- Rollback automatique si échec
- Pas d'écrasement destructif sans confirmation
- Détection installation partielle = propose réparation
```

### Recovery Mode

```bash
/doh:init --repair
→ Mode réparation pour installation corrompue
→ Reconstruction .doh/project-index.json depuis filesystem scan
→ Résolution références orphelines
→ Health check + diagnostic complet
```

### Rollback Capability

```bash
/doh:init --rollback
→ Restaure dernière backup connue
→ Annule dernière installation/upgrade
→ Remet en cohérence filesystem
```

## Outputs & Reporting

### Rapport d'Installation

```bash
🎉 Installation /doh complète!

📊 Statistiques:
  - Épics détectés/créés: 2 (+1 Epic #0)
  - Tâches migrées: 5
  - Fichiers analysés: 127
  - Langue détectée: Français
  - Niveau /doh: Standard

📁 Structure créée:
  ├── .doh/                              # Contenu projet (copié depuis skeleton)
  │   ├── project-index.json             # Index unifié personnalisé
  │   ├── epics/quick/epic0.md           # Epic #0 prêt à utiliser
  │   ├── memory/project/                # Mémoire niveau projet
  │   ├── memory/epics/                  # Mémoire niveau épics
  │   └── memory/agent-sessions/         # Sessions agents
  ├── .claude/doh/                       # Système /doh
  │   ├── skel/                          # Skeleton pour futurs projets
  │   └── templates/ (FR + Symfony)      # Templates
  └── .claude/context/anti-vibe-coding.md

⚡ Commandes disponibles:
  /doh:quick "description"  → Création rapide via Epic #0
  /doh:epic [id]           → Brainstorming épics  
  /doh:task [id]           → Gestion tâches

📋 Next steps:
  1. Tester: /doh:quick "corriger typo menu"
  2. Explorer: Voir .doh/epics/
  3. Workflow: Utiliser traceabilité [DOH #ID] dans commits

✅ /doh system prêt!
```

### Debug Mode

```bash
/doh:init --verbose
→ Logs détaillés de chaque étape
→ Affichage des fichiers scannés
→ Détails des décisions automatiques  
→ Timing des opérations
```

## Spécialisation par Framework

### Symfony (Détecté)

```bash
# Templates adaptés Symfony
- Entity modification templates
- Doctrine migration helpers
- Sonata Admin integration examples
- Webpack Encore build references
```

### Node.js/JavaScript

```bash
# Templates pour projets JS
- Component creation templates  
- Package.json script integration
- Jest/testing framework examples
- Build pipeline references
```

### Générique

```bash
# Templates universels
- Basic PRD/Epic/Task structure
- Git workflow integration
- General development patterns
- Language-agnostic examples
```

## Maintenance & Evolution

### Self-Update Capability

```bash
# Mise à jour système /doh
/doh:init --update-system
→ Télécharge dernière version templates
→ Met à jour schemas + agents  
→ Conserve configuration projet
```

### Health Monitoring

```bash
# Diagnostic périodique
/doh:init --health-check
→ Scan intégrité système
→ Détecte corruptions ou incohérences
→ Rapport santé + recommandations
```

---

*Commande /doh:init - Installation et maintenance intelligente du système /doh*
