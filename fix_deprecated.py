import sys
import os
import re

def replace_with_opacity(directory):
    pattern = re.compile(r'\.withOpacity\((.*?)\)')
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    new_content = pattern.sub(r'.withValues(alpha: \1)', content)
                    
                    if new_content != content:
                        with open(file_path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        print(f"Updated {file_path}")
                except Exception as e:
                    print(f"Error processing {file_path}: {e}")

if __name__ == "__main__":
    search_dir = sys.argv[1] if len(sys.argv) > 1 else 'lib'
    replace_with_opacity(search_dir)
