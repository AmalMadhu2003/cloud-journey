#!/usr/bin/env bash
# Adds this week's log entry to the top of LOG.md from the template.
# Run from anywhere:  newweek   (or: bash scripts/new-week.sh)
set -euo pipefail
cd "$(dirname "$0")/.."

MONDAY="$(date -d "$(date +%F) -$(( $(date +%u) - 1 )) days" +%Y-%m-%d)"
WEEK="Week of $MONDAY"
if grep -q "^## $WEEK" LOG.md; then
  echo "This week's entry already exists in LOG.md"
  exit 0
fi

sed "s/{{WEEK}}/$WEEK/" templates/weekly-log.md > .entry.tmp
awk '
  { print }
  /<!-- entries -->/ && !done { print ""; while ((getline line < ".entry.tmp") > 0) print line; done = 1 }
' LOG.md > LOG.md.tmp && mv LOG.md.tmp LOG.md
rm -f .entry.tmp

echo "Added \"$WEEK\" to LOG.md. Fill it in, then:"
echo "  git add LOG.md && git commit -m \"Log: $WEEK\" && git push"
