"""
Runtime hook for numpy in PyInstaller frozen builds.
Ensures numpy's native DLL dependencies are on the DLL search path
before numpy's C-extensions are imported.

Key insight: numpy._core._multiarray_umath.pyd depends on:
  - libscipy_openblas64_*.dll  (from numpy.libs at site-packages level)
  - msvcp140-*.dll             (from numpy.libs at site-packages level)
These are bundled into app root ('.') in the spec, so we add app root to PATH.
"""
import os
import sys

if getattr(sys, 'frozen', False):
    base = sys._MEIPASS

    # numpy/__init__.py adds DLLs via:
    #   os.path.join(os.path.dirname(__file__), os.pardir, 'numpy.libs')
    # which resolves to: sys._MEIPASS/numpy.libs/
    # Our spec places the DLLs exactly there.
    # We also add it explicitly here as a safety net.
    candidates = [
        os.path.join(base, 'numpy.libs'),      # primary: where spec puts them
        base,                                  # fallback: app root
        os.path.join(base, 'numpy', '.libs'),  # legacy numpy < 2 style
        os.path.join(base, '.libs'),
    ]

    for path in candidates:
        if os.path.isdir(path):
            try:
                os.add_dll_directory(path)
            except (OSError, AttributeError):
                pass
            os.environ['PATH'] = path + os.pathsep + os.environ.get('PATH', '')
