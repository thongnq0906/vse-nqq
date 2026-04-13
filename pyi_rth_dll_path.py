"""
Runtime hook: Add sys._MEIPASS and key subdirs to DLL search path.
Runs before any Python imports in the frozen app.
"""
import os
import sys

if getattr(sys, 'frozen', False):
    base = sys._MEIPASS

    # Add base dir and known DLL subdirs to search path
    # numpy.libs: contains libscipy_openblas64_ and msvcp140 DLLs
    dll_dirs = [base]
    for sub in ['numpy.libs', 'paddle', 'paddle/libs', 'numpy/.libs',
                 'cv2', 'shapely/.libs']:
        full = os.path.join(base, sub)
        if os.path.isdir(full):
            dll_dirs.append(full)

    for d in dll_dirs:
        try:
            os.add_dll_directory(d)
        except (OSError, AttributeError):
            pass

    # Prepend all to PATH
    extra = os.pathsep.join(dll_dirs)
    os.environ['PATH'] = extra + os.pathsep + os.environ.get('PATH', '')
