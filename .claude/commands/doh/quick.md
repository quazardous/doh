# /doh:quick Command

## Description
Express task creation with intelligent analysis, complexity assessment, and automatic guidance toward appropriate granularity. Uses the DOH Project Agent for natural language processing and smart recommendations.

## Usage
```
/doh:quick [description with natural language typing]
```

## Parameters
- `description`: Task description in French with optional type keywords (hotfix, bug, performance, refactor, etc.)

## Examples
- `/doh:quick "corriger bug responsive menu mobile"`
- `/doh:quick "hotfix typo dans titre page contact"`  
- `/doh:quick "refactor méthode authentification utilisateur"`
- `/doh:quick "performance optimiser chargement images"`
- `/doh:quick "améliorer système notification push"`

## Intelligent Processing Flow

### 1. Natural Language Analysis
The DOH Project Agent processes the description to:
- Extract task type from keywords (hotfix, bug, performance, refactor, feature)
- Identify scope and complexity indicators
- Detect vague or incomplete requirements

### 2. Clarification Process
If description is unclear or complex, agent asks targeted questions:
```
Description vague → "Précisions nécessaires : [questions spécifiques]"
Scope ambigu → "Impact : frontend, backend, ou les deux ?"  
Type incertain → "Nature : bug fix, amélioration, ou nouvelle fonctionnalité ?"
```

### 3. Complexity Assessment & Recommendations

#### **Simple & Clear** → Direct Task Creation
```
Input: /doh:quick "hotfix typo page contact"
Output: → Task #145 created in Epic #0 (🔧 Maintenance)
```

#### **Complex but Atomic** → Propose Phasage (Splitting)
```
Input: /doh:quick "optimiser performance authentification"
Analysis: "Détection complexité : backend + frontend
Recommandation PHASAGE :
1. 'Optimiser requêtes DB authentification'  
2. 'Améliorer cache session frontend'
Créer 2 tâches séparées ?"
```

#### **Multi-Component** → Suggest Surclassement (Promotion)
```
Input: /doh:quick "système notification temps réel"
Analysis: "Scope détecté : architecture multi-composant
Recommandation SURCLASSEMENT :
→ Feature 'Notifications Temps Réel' avec tasks :
  - Backend WebSocket setup
  - Frontend notification UI  
  - Database schema extension
Créer Feature ?"
```

## Default Epic #0 Integration

### Auto-Assignment Rules
Tasks created via `/doh:quick` are automatically assigned to Epic #0 unless:
- User specifies different parent: `/doh:quick "task description" --epic=5`
- Agent recommends promotion to Feature/Epic level
- Complexity analysis suggests dedicated epic needed

### Auto-Categorization
Based on keywords in description:
- **🐛 Bug Fixes**: bug, fix, hotfix, corriger, réparer
- **⚡ Performance**: performance, optimiser, accélérer, cache
- **🔧 Maintenance**: refactor, nettoyer, mise à jour, dépendances  
- **📝 Documentation**: documenter, readme, commentaire, doc
- **🎨 UI/UX**: design, interface, style, responsive, mobile

### Epic #0 Graduation Logic
When Epic #0 accumulates related tasks, agent suggests graduation:
```
"Epic #0 contient 6 tâches liées à l'authentification :
Tasks #123, #124, #125, #126, #127, #128

Recommandation : Créer Epic 'Système Authentification' 
et migrer ces tâches ? Cela améliorerait l'organisation."
```

## Agent Invocation
```
Use the DOH Project Agent to process express task creation with intelligent analysis.

Task Description: "{user_input}"
Project Context: MrTroove Symfony application with frontend JavaScript
Language: French for content, English for code identifiers

Process Flow:
1. Analyze description for clarity and complexity
2. Ask clarifying questions if needed  
3. Assess scope and recommend granularity (task/phasage/surclassement)
4. Create appropriate DOH items based on analysis
5. Auto-assign to Epic #0 with proper categorization
6. Ensure task maturity before marking ready for implementation

Follow DOH standards for traceability and file organization.
```

## Output Location
- **Simple Tasks**: `.doh/tasks/task{id}.md` (lié à Epic #0)
- **Promoted Features**: `.doh/features/{mnemonic}/feature{id}.md`  
- **New Epics**: `.doh/epics/{mnemonic}/epic{id}.md`
- **Index Updates**: `.doh/project-index.json` avec métadonnées pour tous les items créés

## Integration Notes
- Works seamlessly with existing DOH command structure
- Maintains backward compatibility with traditional `/doh:task`, `/doh:epic` workflows
- Integrates with `/doh:agent` for autonomous execution handoff
- Supports natural language queries for project status and organization