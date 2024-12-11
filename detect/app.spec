# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['app.py'],  # 主程序入口文件
    pathex=['.'],  # 搜索路径（当前路径）
    binaries=[],
    datas=[
        ('logs/', 'logs/'),  # 将日志目录包含进去
        
        ('requirements.txt', '.')  # 可选：包含requirements.txt
    ],
    hiddenimports=[
        'cv2', 'mediapipe', 'flasgger', 'flask_cors'
    ],
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='app',  # 生成的可执行文件名
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=True,  # 设置为 False 如果需要隐藏控制台
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='app'
)
