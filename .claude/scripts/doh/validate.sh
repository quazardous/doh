#!/bin/bash

echo "Validating DOH System..."
echo ""
echo ""

echo "🔍 Validating DOH System"
echo "======================="
echo ""

errors=0
warnings=0

# Check directory structure
echo "📁 Directory Structure:"
[ -d ".claude" ] && echo "  ✅ .claude directory exists" || { echo "  ❌ .claude directory missing"; ((errors++)); }
[ -d ".doh/prds" ] && echo "  ✅ PRDs directory exists" || echo "  ⚠️ PRDs directory missing"
[ -d ".doh/epics" ] && echo "  ✅ Epics directory exists" || echo "  ⚠️ Epics directory missing"
[ -d ".claude/rules" ] && echo "  ✅ Rules directory exists" || echo "  ⚠️ Rules directory missing"
echo ""

# Check for orphaned files
echo "🗂️ Data Integrity:"

# Check epics have epic.md files
for epic_dir in .doh/epics/*/; do
  [ -d "$epic_dir" ] || continue
  if [ ! -f "$epic_dir/epic.md" ]; then
    echo "  ⚠️ Missing epic.md in $(basename "$epic_dir")"
    ((warnings++))
  fi
done

# Check for tasks without epics
orphaned=$(find .claude -name "[0-9]*.md" -not -path ".doh/epics/*/*" 2>/dev/null | wc -l)
[ $orphaned -gt 0 ] && echo "  ⚠️ Found $orphaned orphaned task files" && ((warnings++))

# Check for broken references
echo ""
echo "🔗 Reference Check:"

for task_file in .doh/epics/*/[0-9]*.md; do
  [ -f "$task_file" ] || continue

  deps=$(grep "^depends_on:" "$task_file" | head -1 | sed 's/^depends_on: *\[//' | sed 's/\]//' | sed 's/,/ /g')
  if [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
    epic_dir=$(dirname "$task_file")
    for dep in $deps; do
      if [ ! -f "$epic_dir/$dep.md" ]; then
        echo "  ⚠️ Task $(basename "$task_file" .md) references missing task: $dep"
        ((warnings++))
      fi
    done
  fi
done

[ $warnings -eq 0 ] && [ $errors -eq 0 ] && echo "  ✅ All references valid"

# Check frontmatter
echo ""
echo "📝 Frontmatter Validation:"
invalid=0

for file in $(find .claude -name "*.md" -path "*/epics/*" -o -path "*/prds/*" 2>/dev/null); do
  if ! grep -q "^---" "$file"; then
    echo "  ⚠️ Missing frontmatter: $(basename "$file")"
    ((invalid++))
  fi
done

[ $invalid -eq 0 ] && echo "  ✅ All files have frontmatter"

# Summary
echo ""
echo "📊 Validation Summary:"
echo "  Errors: $errors"
echo "  Warnings: $warnings"
echo "  Invalid files: $invalid"

if [ $errors -eq 0 ] && [ $warnings -eq 0 ] && [ $invalid -eq 0 ]; then
  echo ""
  echo "✅ System is healthy!"
else
  echo ""
  echo "💡 Run /doh:clean to fix some issues automatically"
fi

exit 0
