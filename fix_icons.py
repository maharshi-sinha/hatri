import os
import re

mapping = {
    'LucideIcons.chrome': 'Icons.web',
    'LucideIcons.smartphone': 'Icons.smartphone',
    'LucideIcons.arrowLeft': 'Icons.arrow_back',
    'LucideIcons.share2': 'Icons.share',
    'LucideIcons.users': 'Icons.people',
    'LucideIcons.messageSquare': 'Icons.message',
    'LucideIcons.edit2': 'Icons.edit',
    'LucideIcons.image': 'Icons.image',
    'LucideIcons.list': 'Icons.list',
    'LucideIcons.settings': 'Icons.settings',
    'LucideIcons.calendarCheck': 'Icons.event_available',
    'LucideIcons.bookmark': 'Icons.bookmark',
    'LucideIcons.history': 'Icons.history',
    'LucideIcons.barChart2': 'Icons.bar_chart',
    'LucideIcons.chevronRight': 'Icons.chevron_right',
    'LucideIcons.slidersHorizontal': 'Icons.tune',
    'LucideIcons.plus': 'Icons.add',
    'LucideIcons.calendar': 'Icons.calendar_today',
    'LucideIcons.mapPin': 'Icons.location_on',
    'LucideIcons.user': 'Icons.person'
}

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            original_content = content
            for k, v in mapping.items():
                content = content.replace(k, v)
            
            # Remove the import statement
            content = re.sub(r"import 'package:lucide_icons/lucide_icons\.dart';\n?", "", content)
            
            if content != original_content:
                with open(path, 'w') as f:
                    f.write(content)
                print(f"Updated {path}")
