# DOH Workflow Guide

## PRD → Epic → Feature → Task

This guide shows how to use the complete DOH hierarchy for large projects requiring proper planning.

## Example: Eating Good Tacos

### 1. Create PRD

```bash
/doh:prd "eating good tacos"
```

**Result**: Creates `prd1.md` with requirements for the perfect taco experience.

### 2. Break PRD into Epics

```bash
/doh:prd-epics !1
```

**Claude creates**:

- Epic !2: "Taco selection and preparation"
- Epic !3: "Perfect drinking companion"
- Epic !4: "Entertainment while eating"

### 3. Break Epic into Features

```bash
/doh:epic-features !3  # Focus on drinking epic
```

**Claude creates**:

- Feature !5: "Beer selection and temperature"
- Feature !6: "Proper drinking timing"
- Feature !7: "Pairing with taco flavors"

### 4. Break Feature into Tasks

```bash
/doh:feature-tasks !5  # Beer selection feature
```

**Claude creates**:

- Task !8: "Research best beer types for tacos"
- Task !9: "Set up proper beer cooling system"
- Task !10: "Create beer-taco pairing guide"

### 5. Implement with Agent

```bash
/doh:agent !9  # "Set up proper beer cooling system"
```

**Result**: Autonomous implementation while watching The Simpsons.

---

## Final Structure

```text
.doh/
├── prds/prd1.md (Eating good tacos)
├── epics/perfect-drinking-companion/epic3.md
├── features/beer-selection/feature5.md
└── tasks/task9.md (Beer cooling system)
```

**Traceability**: PRD !1 → Epic !3 → Feature !5 → Task !9 → Perfect tacos + beer + Simpsons

---

## See Also

**✅ Completed this guide?** Next steps:

- **Practice with simple tasks**: Try `/doh:quick "your task here"`  
- **Learn patterns**: [docs/workflow-patterns.md](./docs/workflow-patterns.md) - When to use each workflow  
- **See real examples**: [docs/workflow-examples.md](./docs/workflow-examples.md) - Complete project scenarios  
- **All commands**: [docs/commands.md](./docs/commands.md) - Complete command reference

**🔧 For developers**: [DEVELOPMENT.md](./DEVELOPMENT.md) - Internal development patterns
