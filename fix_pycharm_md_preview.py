#!/usr/bin/env python3

import os
from pathlib import Path

if __name__ == '__main__':
    home_path = Path.home()
    jetbrains_cache_dir = os.path.join(home_path, '.cache/JetBrains/')
    assert os.path.exists(jetbrains_cache_dir), "JetBrains cache dir not exists"
    pycharm_jcef_cache_dirs = [os.path.join(jetbrains_cache_dir, d, 'jcef_cache')
                               for d in os.listdir(jetbrains_cache_dir) if d.startswith('PyCharm')]
    for cache_dir in pycharm_jcef_cache_dirs:
        singleton_files = [f for f in os.listdir(cache_dir) if f.startswith('Singleton')]
        if singleton_files:
            print(f"Removing lock file(s) from {cache_dir}")
            os.system(f"rm {os.path.join(cache_dir, 'Singleton*')}")
    print("Done!")
