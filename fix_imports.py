#!/usr/bin/env python3
import os
import re
import glob

def fix_imports(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Check if strings.Contains is used
    if 'strings.Contains' not in content:
        return False

    # Check if strings is already imported
    if '"strings"' in content:
        return False

    # Add strings import after testing import
    content = re.sub(
        r'(import \(\n\t"testing")',
        r'\1\n\t"strings"',
        content
    )

    with open(filepath, 'w') as f:
        f.write(content)

    return True

# Fix all test files
test_files = glob.glob('/auto/cat-sol/ws/phannguy/terraform-provider-catalystcenter/catalystcenter/*_test.go')
fixed_count = 0

for filepath in test_files:
    if fix_imports(filepath):
        print(f"Fixed: {os.path.basename(filepath)}")
        fixed_count += 1

print(f"\nTotal files fixed: {fixed_count}")