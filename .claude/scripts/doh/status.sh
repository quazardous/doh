#!/bin/bash
source .claude/scripts/doh/lib/dohenv.sh

echo "Getting status..."
echo ""
echo ""


echo "📊 Project Status"
echo "================"
echo ""

echo "📄 PRDs:"
if [ -d ".doh/prds" ]; then
  total=$(ls .doh/prds/*.md 2>/dev/null | wc -l)
  echo "  Total: $total"
else
  echo "  No PRDs found"
fi

echo ""
echo "📚 Epics:"
if [ -d ".doh/epics" ]; then
  total=$(ls -d .doh/epics/*/ 2>/dev/null | wc -l)
  echo "  Total: $total"
else
  echo "  No epics found"
fi

echo ""
echo "📝 Tasks:"
if [ -d ".doh/epics" ]; then
  total=$(find .doh/epics -name "[0-9]*.md" 2>/dev/null | wc -l)
  open=$(find .doh/epics -name "[0-9]*.md" -exec grep -l "^status: *open" {} \; 2>/dev/null | wc -l)
  closed=$(find .doh/epics -name "[0-9]*.md" -exec grep -l "^status: *closed" {} \; 2>/dev/null | wc -l)
  echo "  Open: $open"
  echo "  Closed: $closed"
  echo "  Total: $total"
else
  echo "  No tasks found"
fi

exit 0
