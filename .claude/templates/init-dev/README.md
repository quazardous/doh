# Init-Dev Templates

## ⚠️ Templates d'illustration

**IMPORTANT**: Ces templates sont fournis à titre d'**illustration** et ne sont **pas exhaustifs**. Ils servent de base de départ pour comprendre la structure et peuvent nécessiter des adaptations selon vos besoins spécifiques.

## Structure

```
.claude/templates/init-dev/
├── common/                     # Templates communs à tous les stacks
│   ├── docker-compose.env-docker   # Variables d'environnement
│   ├── docker-compose-base.yml     # Base docker-compose
│   ├── traefik.yml-docker          # Configuration Traefik
│   ├── dynamic.yaml-docker         # Configuration TLS
│   ├── Makefile                    # Commandes de développement
│   └── scripts/
│       └── install-deps.sh         # Installation des dépendances
├── stacks/                     # Templates spécifiques par stack
│   ├── node/                   # Stack Node.js
│   ├── php/                    # Stack PHP
│   └── python/                 # Stack Python
└── services/                   # Services Docker modulaires
    ├── postgres.yml           # PostgreSQL + Adminer
    ├── mysql.yml              # MySQL + phpMyAdmin
    ├── redis.yml              # Redis
    └── mailhog.yml            # MailHog
```

## Utilisation

Ces templates sont utilisés par la commande `/doh:init-dev` pour générer des environnements de développement. Ils peuvent être personnalisés selon vos besoins :

### Personnalisation des templates

1. **Stacks supplémentaires** : Ajoutez de nouveaux dossiers dans `stacks/`
2. **Services additionnels** : Créez de nouveaux fichiers `.yml` dans `services/`
3. **Outils de linting** : Adaptez les `Dockerfile.linter` selon vos standards
4. **Configuration** : Modifiez les templates de configuration selon vos conventions

### Variables de substitution

Les templates utilisent des variables de substitution :
- `{{PROJECT_NAME}}` - Nom du projet (détecté depuis le nom du répertoire)
- Ajoutez d'autres variables selon vos besoins

### Gestion des permissions (UID/GID)

**⚠️ UID/GID ne sont PAS dans les templates**

Les permissions sont gérées automatiquement par :

**Option 1 - Via Makefile** :
```make
export UID := $(shell id -u)  # Makefile syntax
export GID := $(shell id -g)
```

**Option 2 - Via script bash** :
```bash
export UID     # UID est déjà défini en bash
export GID=$(id -g)
```

**Flux commun** :
```
Détection (make/script) → docker-compose.yml (args:) → Dockerfile (application)
```

Dans tous les cas :
- **docker-compose.yml** transmet via `args:` aux Dockerfiles lors du build
- **Dockerfiles** créent/modifient l'utilisateur interne avec les UID/GID du host

Aucune configuration manuelle d'UID/GID n'est nécessaire.

### Versions des dépendances

⚠️ **Les numéros de versions dans les templates sont à titre d'illustration**

La commande `/doh:init-dev` doit :
- Rechercher les versions les plus récentes au moment de l'initialisation
- Remplacer les versions d'exemple par les versions actuelles
- Utiliser des API ou des sources fiables pour obtenir les dernières versions stables

**Exemples de sources pour versions à jour** :
- Node.js : npm registry API, Docker Hub
- PHP : Packagist API, Docker Hub  
- Python : PyPI API, Docker Hub
- Images Docker : Docker Hub API

### Containers de linting

Chaque stack inclut un container de linting séparé (`linter.yml` + `Dockerfile.linter`) pour :
- ✅ Éviter les conflits de versions d'outils
- ✅ Standardiser les outils pour l'équipe
- ✅ Permettre des environnements de linting reproductibles

**Usage des linters** :
```bash
# Démarrer le container de linting
docker compose --profile tools up -d linter

# Utiliser les outils de linting
docker compose exec linter eslint src/        # Node.js
docker compose exec linter phpstan analyze   # PHP  
docker compose exec linter black .           # Python
```

### Support dotenv (.env)

Tous les stacks incluent le support dotenv pour la gestion des variables d'environnement :

**Node.js** : Package `dotenv` avec `require('dotenv').config()`
**PHP** : Package `vlucas/phpdotenv` avec `Dotenv::createImmutable()`  
**Python** : Package `python-dotenv` avec `load_dotenv()`

**Flux d'usage** :
```bash
# 1. Copier le template d'environnement
cp docker-compose.env .env

# 2. Éditer les variables locales
# .env est git-ignoré pour la sécurité

# 3. L'application charge automatiquement .env
# Variables disponibles dans process.env / $_ENV / os.getenv()
```

**Sécurité** :
- `.env` est git-ignoré par défaut
- `docker-compose.env-docker` est versionné comme template
- Variables sensibles maskées dans les logs de debug

### Accès au container principal

Le service `app` est **toujours le container qui exécute l'application web principale** :

**Node.js** : Container avec Express/Next.js/etc. qui sert l'API/site web  
**PHP** : Container PHP-FPM qui traite les requêtes web (+ nginx séparé)  
**Python** : Container Django/FastAPI qui sert l'application web

**Workflow de développement typique** :
```bash
make dev         # Lance ton application web
make sh          # Entre dans le container pour voir ce qui s'y passe
                 # - Consulter les logs
                 # - Déboguer ton code
                 # - Installer des packages
                 # - Lancer des commandes
                 
make shell-mysql # Entre dans la base de données si besoin
make shell-redis # Entre dans le cache si besoin
```

**Différence importante** :
- `app` = Container qui **exécute** ton application web/API
- `linter` = Container qui ne fait que les **outils de développement**

## Limitations et Extensions

### Ces templates sont des bases minimales

- **Node.js** : Configuration ESLint/Prettier basique
- **PHP** : Setup Laravel/Symfony générique
- **Python** : Configuration Django/FastAPI simple

### Extensions suggérées

- Tests unitaires et d'intégration
- CI/CD pipelines
- Monitoring et observabilité
- Configuration de sécurité avancée
- Optimisations de performance

## Contribution

Pour étendre ou améliorer ces templates :

1. Suivez la structure existante
2. Documentez les nouvelles variables de substitution
3. Testez avec différents projets
4. Maintenez la simplicité pour faciliter l'adoption

**Principe** : Ces templates doivent rester des **points de départ** simples et adaptables, non des solutions complètes clé-en-main.