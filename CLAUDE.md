# DOH Project Configuration for AI Development

**Version**: 1.2 (2025-08-30)

## 🚨 CLAUDE: READ AI.md FIRST 🚨

**PRIORITY DELEGATION**: Before reading this file or any other documentation:

1. **ALWAYS READ `./AI.md` FIRST** - Complete compiled guide with all critical information
2. **Check AI.md source version** - If shows "Source Version: CLAUDE.md v1.2", AI.md is current and sufficient
3. **If AI.md shows older version**: Consult this file (CLAUDE.md) and other source documents for latest information
4. **AI.md contains**: Next Task ID, task creation protocol, command execution workflows, project context

**🎯 AI.md shows v1.2**: You're ready to work - all critical info compiled and current  
**⚠️ AI.md shows older version**: Read additional documentation or run `/dd:mkai --compile` to refresh

---

## 🚫 EXPLICIT PROHIBITION: External Tool Attribution

**FORBIDDEN**: All external tool attribution is explicitly prohibited in this project:

- ❌ NO "Generated with [Claude Code]" in any commits, documentation, or code
- ❌ NO "Co-Authored-By: Claude" or similar external tool attributions
- ❌ NO references to specific AI tools, IDEs, or development environments in code/commits
- ✅ This project stands as independent professional software

**Enforcement**: Any attribution to external tools must be removed immediately upon detection.

## Claude-Specific Behavioral Rules

### **Development Approach**

- **By default, brainstorm and present plans** - only start coding when explicitly asked (except for simple direct
  orders)
- **Only work on complex tasks if there's a mature TODO entry** - complex work requires proper planning and
  documentation
- **Always create a TODO for complex tasks** - moving one file is simple, restructuring directories/systems is complex
  and requires a TODO
- **When uncertain about task complexity, ask if a TODO should be created** - better to check than assume
- **No comments unless explicitly requested**

### **Project Language**

This project is **full English** - all code, documentation, comments, and files must be in English for universal
compatibility and distribution.

## Documentation References

### **Primary Development Documentation**

**[DEVELOPMENT.md](./DEVELOPMENT.md)** - Complete day-to-day development guide containing:

- Task creation protocol and naming convention system
- Markdown quality control workflow and commands
- DOH development context and patterns
- Dependencies philosophy and technical requirements
- Architecture principles and file organization

### **DOH Runtime Documentation** (Not applicable to DOH-DEV)

**Note**: `WORKFLOW.md` is for DOH runtime system users (end users of the DOH project management system). Since we are
developing the DOH system itself (DOH-DEV), we do not use the DOH runtime workflow - we use the structured TODO system
documented in DEVELOPMENT.md.

---

**This file provides Claude-specific behavioral configuration. All detailed development information is in DEVELOPMENT.md
to avoid duplication and maintain single sources of truth.**
