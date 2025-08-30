# Stratégie Worktree avec IA

## Problématique

Les worktrees Git nécessitent le contexte IA (`.claude/`) pour que l'assistant comprenne le project et le système DOH.

## Solution Architecture

### Structure Cible

```text
/home/david/Private/dev/projects/
├── myproject/                      # Project principal
│   ├── .claude/                   # Config IA originale
│   │   ├── doh/                   # Système DOH (specs)
│   │   ├── commands/              # Commandes Claude
│   │   └── agents/                # Agents DOH
│   └── .doh/                      # Contenu project DOH
│       ├── project-index.json     # Index unifié
│       ├── epics/                 # Epics project
│       ├── tasks/                 # Tasks project
│       └── memory/                # Mémoire persistante
│
├── myproject-epic-auth/            # Worktree pour epic auth
│   ├── .claude/                   # COPIE complète de .claude/
│   └── .doh/                      # COPIE complète de .doh/ (permet divergence)
│
└── myproject-feature-login/        # Worktree pour feature
    ├── .claude/                   # COPIE complète de .claude/
    └── .doh/                      # COPIE complète de .doh/ (permet divergence)
```

## ⚠️ Stratégie Recommandée

- **`.doh/` versionné** = Automatiquement dans worktrees via Git (permet divergence)
- **`.claude/` en symlink** = Partagé entre tous les worktrees (cohérence guarantee)

## Stratégie de Mise en Place

### 1. Création Worktree avec Setup Recommandé

```bash
#!/bin/bash
# Script: create-doh-worktree.sh

TYPE=$1  # epic|feature|task
NAME=$2  # nom-descriptif (ex: auth, login-ui)
PROJECT_NAME=$(basename $(pwd))  # Détecte nom project
BRANCH="${TYPE}/${NAME}"
WORKTREE_DIR="../${PROJECT_NAME}-worktree-${TYPE}-${NAME}"

# Créer worktree Git (inclut automatiquement .doh/ versionné)
git worktree add "$WORKTREE_DIR" "$BRANCH"

# Créer symlink vers .claude/ principal (RECOMMANDÉ)
ln -s "$(pwd)/.claude" "$WORKTREE_DIR/.claude"

echo "✅ Worktree créé: $WORKTREE_DIR"
echo "   Branch: $BRANCH"
echo "   Claude context: Symlink vers principal (.claude/)"
echo "   DOH state: Déjà présent via Git (.doh/ versionné)"
```

### 2. Advantages de cette Approach

#### Copie de `.claude/`

- ✅ **Contexte complete** : L'IA a toutes les infos du project
- ✅ **Isolation** : Modifications locales possibles si nécessaire
- ✅ **Compatibilité** : Fonctionne même si l'IA ne suit pas les symlinks
- ✅ **CLAUDE.md présent** : Instructions project disponibles

#### Copie de `.doh/`

- ✅ **Divergence possible** : Chaque worktree peut créer ses propres PRDs/epics/tasks
- ✅ **Merge Git standard** : Les fichiers .doh/ sont mergés comme tout autre code
- ✅ **Traçabilité complète** : L'historique des changements DOH dans Git
- ✅ **Branches expérimentales** : Possibilité de tester des restructurations DOH

### 3. Synchronisation et Merge

#### Lors du Merge Back

```bash
# Dans worktree - commit des changements DOH
git add .doh/
git commit -m "[#123] Ajout tasks et mise à jour index pour epic auth"

# Merge vers main
git checkout main
git merge epic/auth

# Résolution conflicts si nécessaire
# Typiquement sur project-index.json si counters ont divergé
git mergetool .doh/project-index.json

# Retour au project principal
cd ../myproject
git pull  # Récupérer les changements mergés
git worktree remove ../myproject-epic-auth
```

### 4. Cas Particuliers

#### Modifications .claude/ dans Worktree

Si des modifications de `.claude/` sont nécessaires dans un worktree :

```bash
# Les changements restent locaux au worktree
# Au merge, décider si propager au principal
diff -r .claude/ ../myproject/.claude/
```

#### Multiple Worktrees Actifs

```text
myproject/                 # Principal
├── .doh/                 # État DOH principal
│
├── myproject-epic-auth/   # Worktree 1
│   └── .doh/            # Copie DOH (peut créer tasks spécifiques)
│
├── myproject-epic-ui/     # Worktree 2
│   └── .doh/            # Copie DOH (peut créer son epic UI)
│
└── myproject-fix-bug/     # Worktree 3
    └── .doh/            # Copie DOH (ajoute task bug à Epic #0)
```

Chaque worktree peut faire évoluer sa copie de `.doh/`, les changements sont mergés via Git.

## Implémentation dans autonomous-execution-agent

### Commande `/doh:agent`

```javascript
// Pseudo-code pour agent
function createWorktreeForTask(taskId) {
  const task = loadTask(taskId);
  const epic = task.parent;

  // Déterminer type et nom
  const type = epic.id === 0 ? "fix" : "epic";
  const name = sanitizeName(task.title);

  // Créer worktree avec setup complete
  execSync(`./scripts/create-doh-worktree.sh ${type} ${name}`);

  // Naviguer vers worktree
  process.chdir(`../${projectName}-${type}-${name}`);

  // L'agent a maintenant :
  // - Le code dans la bonne branche
  // - .claude/ avec tout le contexte
  // - .doh/ lié au principal pour état unifié
}
```

## Bénéfices Finaux

1. **Isolation Complète** : Chaque worktree peut diverger (code ET organisation DOH)
2. **Contexte Préservé** : L'IA fonctionne parfaitement
3. **Merge Standard** : Git gère les conflicts sur `.doh/` comme sur le code
4. **Parallélisation** : Multiple agents sur différents worktrees
5. **Flexibilité** : Possibilité d'expérimenter avec la structure DOH

## Gérer les Conflicts DOH

### Conflicts Typiques

1. **project-index.json counters**

   ```json
   <<<<<<< HEAD
   "next_id": 45,
   =======
   "next_id": 43,
   >>>>>>> epic/auth
   ```

   **Solution**: Prendre le plus grand numéro

2. **Nouvelles tasks dans même epic**

   ```json
   "epics_to_tasks": {
     "0": [1, 2, 3, 4, 5]  // Merge: combiner les listes
   }
   ```

3. **Fichiers .md créés**
   - Si même ID mais contenu différent : résolution manuelle
   - Si IDs différents : tout garder

## Script d'Installation

Créer `/scripts/setup-worktree-system.sh` :

```bash
#!/bin/bash
# Installation du système worktree pour DOH

echo "📦 Installation système worktree DOH..."

# Créer dossier scripts si nécessaire
mkdir -p scripts

# Créer script de création worktree
cat > scripts/create-doh-worktree.sh << 'EOF'
#!/bin/bash
# [Contenu du script ci-dessus]
EOF

chmod +x scripts/create-doh-worktree.sh

echo "✅ Système worktree DOH installé"
echo "Usage: ./scripts/create-doh-worktree.sh [epic|feature|task] [name]"
```

## Workflow Recommandé

### Création Feature

```bash
# 1. Depuis main, créer worktree
./scripts/create-doh-worktree.sh feature login-redesign

# 2. Dans worktree, créer tasks DOH
cd ../myproject-feature-login-redesign
/doh:quick "refactorer formulaire login"
/doh:quick "ajouter validation côté client"

# 3. Développer et committer
git add .
git commit -m "[#123] Implementation login redesign avec tasks DOH"

# 4. Merge back
git checkout main
git merge feature/login-redesign
```

---

_Cette stratégie permet une divergence contrôlée des états DOH avec merge Git standard, garantissant flexibilité et
traçabilité._
