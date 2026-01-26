#!/bin/bash
# Cleanup script for Antigravity cache
# Run periodically or when Antigravity is slow/crashing

echo "=== Antigravity Cleanup Script ==="
echo ""

# Check current size
echo "Current Antigravity cache size:"
du -sh ~/.gemini/antigravity/ 2>/dev/null
echo ""

# Clean old browser recordings (keep most recent session)
echo "Cleaning old browser recordings..."
cd ~/.gemini/antigravity/browser_recordings 2>/dev/null
if [ $? -eq 0 ]; then
    ls -t | tail -n +2 | xargs rm -rf 2>/dev/null
    echo "  - Old recordings removed"
else
    echo "  - No recordings folder found"
fi

# Clean old brain sessions (keep 5 most recent)
echo "Cleaning old brain sessions..."
cd ~/.gemini/antigravity/brain 2>/dev/null
if [ $? -eq 0 ]; then
    ls -t | tail -n +6 | xargs rm -rf 2>/dev/null
    echo "  - Old brain sessions removed (kept 5 most recent)"
else
    echo "  - No brain folder found"
fi

# Clean old implicit memory (older than 7 days)
echo "Cleaning old implicit memory..."
find ~/.gemini/antigravity/implicit -type f -mtime +7 -delete 2>/dev/null
echo "  - Files older than 7 days removed"

# Final size
echo ""
echo "Final Antigravity cache size:"
du -sh ~/.gemini/antigravity/ 2>/dev/null
du -sh ~/.gemini/antigravity/*/ 2>/dev/null

echo ""
echo "=== Cleanup Complete ==="
