#!/usr/bin/env python3
import sys

path = sys.argv[1]
with open(path) as f:
    text = f.read()

# The exact pattern: disable_overscan=1\n\ followed by newline, empty line, then "
old = 'disable_overscan=1\\n\\\n\n"'
new = ('disable_overscan=1\\n\\\n'
       '\\n\\\n'
       '# USB-C gadget mode\\n\\\n'
       'dtoverlay=dwc2\\n\\\n'
       '"')

if 'dtoverlay=dwc2' in text:
    print('dtoverlay=dwc2 already present in file')
elif old in text:
    text = text.replace(old, new)
    print('Inserted dtoverlay=dwc2 into RPI_EXTRA_CONFIG')
else:
    print('WARNING: Could not find exact insertion point, trying alternate')
    # Try without empty line
    old2 = 'disable_overscan=1\\n\\\n"'
    if old2 in text:
        text = text.replace(old2, new)
        print('Inserted dtoverlay=dwc2 (alt pattern)')
    else:
        print('ERROR: No matching pattern found')
        sys.exit(1)

# Ensure KERNEL_MODULE_AUTOLOAD has dwc2 g_ether
if 'dwc2 g_ether' not in text:
    text += '\n# --- USB-C gadget Ethernet ---\nKERNEL_MODULE_AUTOLOAD:append = " dwc2 g_ether"\n'
    print('Added dwc2 g_ether to KERNEL_MODULE_AUTOLOAD')
else:
    print('dwc2 g_ether already in KERNEL_MODULE_AUTOLOAD')

with open(path, 'w') as f:
    f.write(text)
print('local.conf updated successfully')
