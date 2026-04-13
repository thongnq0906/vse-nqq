"""
Tiny launcher for Video Subtitle Extractor (portable build).
No external dependencies - only stdlib (os, sys, subprocess).
PyInstaller can compile this without any issues.

Layout expected:
  VideoSubtitleExtractor.exe   <- this compiled launcher
  gui.py
  backend/
  ui/
  config/
  design/
  _python/
    python.exe
    python312.dll
    ...
    DLLs/
    Lib/
      site-packages/
"""

import os
import sys
import subprocess


def main():
    if getattr(sys, 'frozen', False):
        base = os.path.dirname(sys.executable)
    else:
        base = os.path.dirname(os.path.abspath(__file__))

    py_dir  = os.path.join(base, '_python')
    python  = os.path.join(py_dir, 'python.exe')
    script  = os.path.join(base, 'gui.py')

    if not os.path.isfile(python):
        import ctypes
        ctypes.windll.user32.MessageBoxW(
            0,
            f'Không tìm thấy Python tại:\n{python}\n\nVui lòng giải nén đúng cấu trúc thư mục.',
            'Video Subtitle Extractor - Lỗi',
            0x10
        )
        return

    env = os.environ.copy()

    sp   = os.path.join(py_dir, 'Lib', 'site-packages')
    dlls = os.path.join(py_dir, 'DLLs')
    np_libs = os.path.join(sp, 'numpy.libs')

    # Prepend all Python dirs to PATH so DLLs are found
    extra_paths = [py_dir, dlls, base]
    if os.path.isdir(np_libs):
        extra_paths.insert(0, np_libs)

    env['PATH']       = os.pathsep.join(extra_paths) + os.pathsep + env.get('PATH', '')
    env['PYTHONHOME'] = py_dir
    env['PYTHONPATH'] = sp

    subprocess.Popen([python, script], env=env, cwd=base)


if __name__ == '__main__':
    main()
