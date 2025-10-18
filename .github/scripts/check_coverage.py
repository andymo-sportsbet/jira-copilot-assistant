#!/usr/bin/env python3
import sys
from xml.etree import ElementTree as ET

XML = 'coverage.xml'
try:
    tree = ET.parse(XML)
except Exception as e:
    print(f'Failed to parse {XML}: {e}')
    sys.exit(1)

root = tree.getroot()

# Sum coverage for files under mcp-server/
covered = 0
total = 0
for cls in root.findall('.//class'):
    filename = cls.get('filename') or ''
    if filename.startswith('mcp-server/') or '/mcp-server/' in filename:
        # count lines
        for line in cls.findall('.//line'):
            total += 1
            try:
                hits = int(line.get('hits', '0'))
            except Exception:
                hits = 0
            if hits > 0:
                covered += 1

if total == 0:
    # fallback: use overall metrics if no mcp-server files found
    cov = root
    lines_covered = int(cov.get('lines-covered') or cov.get('lines-covered', '0')) if cov is not None else 0
    lines_valid = int(cov.get('lines-valid') or cov.get('lines-valid', '0')) if cov is not None else 0
    if lines_valid == 0:
        print('No coverage data found for mcp-server and overall')
        sys.exit(1)
    percent = (lines_covered / lines_valid) * 100
else:
    percent = (covered / total) * 100

print(f'Coverage for mcp-server: {percent:.1f}% (covered {covered} / total {total})')
if percent < 80.0:
    print('Coverage below 80% — failing')
    sys.exit(2)
print('Coverage threshold met')
