import pandas as pd
import matplotlib.pyplot as plt
import re
from datetime import datetime

# 解析日志数据
log_data = """
2024-12-19 00:21:22,167 - INFO - CPU Usage: 0.0%
2024-12-19 00:21:22,167 - INFO - Memory Usage: 101.01 MB
2024-12-19 00:21:22,167 - INFO - Network - Sent: 874668.16 MB, Received: 439067.46 MB
2024-12-19 00:21:22,167 - INFO - Disk - Read: 2369435.60 MB, Write: 1238180.93 MB
2024-12-19 00:21:24,612 - INFO - CPU Usage: 18.8%
2024-12-19 00:21:24,612 - INFO - Memory Usage: 121.15 MB
2024-12-19 00:21:24,612 - INFO - Network - Sent: 874668.18 MB, Received: 439067.47 MB
2024-12-19 00:21:24,612 - INFO - Disk - Read: 2369435.60 MB, Write: 1238181.70 MB
2024-12-19 00:21:28,188 - INFO - CPU Usage: 0.0%
2024-12-19 00:21:28,188 - INFO - Memory Usage: 101.01 MB
2024-12-19 00:21:28,188 - INFO - Network - Sent: 874668.18 MB, Received: 439067.47 MB
2024-12-19 00:21:28,188 - INFO - Disk - Read: 2369435.65 MB, Write: 1238182.84 MB
2024-12-19 00:21:28,676 - INFO - Video feed started at Thu Dec 19 00:21:28 2024
2024-12-19 00:21:28,676 - INFO - Streaming video from camera index 0
2024-12-19 00:21:30,633 - INFO - CPU Usage: 17.2%
2024-12-19 00:21:30,633 - INFO - Memory Usage: 203.54 MB
2024-12-19 00:21:30,633 - INFO - Network - Sent: 874668.18 MB, Received: 439067.47 MB
2024-12-19 00:21:30,633 - INFO - Disk - Read: 2369435.68 MB, Write: 1238183.54 MB
2024-12-19 00:21:34,211 - INFO - CPU Usage: 0.0%
2024-12-19 00:21:34,212 - INFO - Memory Usage: 101.01 MB
2024-12-19 00:21:34,212 - INFO - Network - Sent: 874668.19 MB, Received: 439067.48 MB
2024-12-19 00:21:34,212 - INFO - Disk - Read: 2369437.24 MB, Write: 1238666.85 MB
2024-12-19 00:21:36,655 - INFO - CPU Usage: 28.1%
2024-12-19 00:21:36,656 - INFO - Memory Usage: 261.54 MB
2024-12-19 00:21:36,656 - INFO - Network - Sent: 874668.20 MB, Received: 439067.48 MB
2024-12-19 00:21:36,656 - INFO - Disk - Read: 2369437.31 MB, Write: 1238671.31 MB
2024-12-19 00:21:40,234 - INFO - CPU Usage: 0.0%
2024-12-19 00:21:40,234 - INFO - Memory Usage: 101.01 MB
2024-12-19 00:21:40,235 - INFO - Network - Sent: 874668.21 MB, Received: 439067.49 MB
2024-12-19 00:21:40,235 - INFO - Disk - Read: 2369437.84 MB, Write: 1238678.33 MB
2024-12-19 00:21:42,679 - INFO - CPU Usage: 23.4%
2024-12-19 00:21:42,679 - INFO - Memory Usage: 262.48 MB
2024-12-19 00:21:42,679 - INFO - Network - Sent: 874668.21 MB, Received: 439067.49 MB
2024-12-19 00:21:42,680 - INFO - Disk - Read: 2369438.03 MB, Write: 1238680.34 MB
2024-12-19 00:21:46,257 - INFO - CPU Usage: 0.0%
2024-12-19 00:21:46,257 - INFO - Memory Usage: 101.01 MB
2024-12-19 00:21:46,257 - INFO - Network - Sent: 874668.23 MB, Received: 439067.50 MB
2024-12-19 00:21:46,257 - INFO - Disk - Read: 2369438.03 MB, Write: 1238686.88 MB
2024-12-19 00:21:48,702 - INFO - CPU Usage: 15.6%
2024-12-19 00:21:48,702 - INFO - Memory Usage: 262.49 MB
2024-12-19 00:21:48,702 - INFO - Network - Sent: 874668.24 MB, Received: 439067.50 MB
2024-12-19 00:21:48,702 - INFO - Disk - Read: 2369439.04 MB, Write: 1238691.85 MB
2024-12-19 00:21:52,281 - INFO - CPU Usage: 0.0%
2024-12-19 00:21:52,281 - INFO - Memory Usage: 101.01 MB
2024-12-19 00:21:52,282 - INFO - Network - Sent: 874668.25 MB, Received: 439067.50 MB
2024-12-19 00:21:52,282 - INFO - Disk - Read: 2369439.20 MB, Write: 1238696.35 MB
2024-12-19 00:21:54,728 - INFO - CPU Usage: 17.2%
2024-12-19 00:21:54,728 - INFO - Memory Usage: 262.45 MB
2024-12-19 00:21:54,729 - INFO - Network - Sent: 874668.26 MB, Received: 439067.50 MB
2024-12-19 00:21:54,729 - INFO - Disk - Read: 2369439.31 MB, Write: 1238700.86 MB
2024-12-19 00:21:58,303 - INFO - CPU Usage: 0.0%
2024-12-19 00:21:58,303 - INFO - Memory Usage: 101.01 MB
2024-12-19 00:21:58,303 - INFO - Network - Sent: 874668.27 MB, Received: 439067.51 MB
2024-12-19 00:21:58,303 - INFO - Disk - Read: 2369439.31 MB, Write: 1238707.81 MB
2024-12-19 00:22:00,751 - INFO - CPU Usage: 17.2%
2024-12-19 00:22:00,751 - INFO - Memory Usage: 262.55 MB
2024-12-19 00:22:00,752 - INFO - Network - Sent: 874668.27 MB, Received: 439067.51 MB
2024-12-19 00:22:00,752 - INFO - Disk - Read: 2369439.56 MB, Write: 1238743.79 MB
2024-12-19 00:22:04,334 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:04,335 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:04,335 - INFO - Network - Sent: 874668.29 MB, Received: 439067.51 MB
2024-12-19 00:22:04,335 - INFO - Disk - Read: 2369439.85 MB, Write: 1238751.04 MB
2024-12-19 00:22:06,774 - INFO - CPU Usage: 23.4%
2024-12-19 00:22:06,774 - INFO - Memory Usage: 262.56 MB
2024-12-19 00:22:06,774 - INFO - Network - Sent: 874668.30 MB, Received: 439067.51 MB
2024-12-19 00:22:06,775 - INFO - Disk - Read: 2369440.10 MB, Write: 1238754.83 MB
2024-12-19 00:22:10,360 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:10,361 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:10,361 - INFO - Network - Sent: 874668.31 MB, Received: 439067.52 MB
2024-12-19 00:22:10,361 - INFO - Disk - Read: 2369442.46 MB, Write: 1238774.82 MB
2024-12-19 00:22:12,798 - INFO - CPU Usage: 7.8%
2024-12-19 00:22:12,798 - INFO - Memory Usage: 262.63 MB
2024-12-19 00:22:12,798 - INFO - Network - Sent: 874668.32 MB, Received: 439067.53 MB
2024-12-19 00:22:12,798 - INFO - Disk - Read: 2369442.47 MB, Write: 1238775.61 MB
2024-12-19 00:22:16,386 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:16,386 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:16,386 - INFO - Network - Sent: 874668.32 MB, Received: 439067.53 MB
2024-12-19 00:22:16,386 - INFO - Disk - Read: 2369442.63 MB, Write: 1238777.16 MB
2024-12-19 00:22:18,818 - INFO - CPU Usage: 43.8%
2024-12-19 00:22:18,818 - INFO - Memory Usage: 262.65 MB
2024-12-19 00:22:18,818 - INFO - Network - Sent: 874668.32 MB, Received: 439067.53 MB
2024-12-19 00:22:18,819 - INFO - Disk - Read: 2369442.65 MB, Write: 1238777.70 MB
2024-12-19 00:22:22,407 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:22,407 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:22,407 - INFO - Network - Sent: 874668.33 MB, Received: 439067.54 MB
2024-12-19 00:22:22,408 - INFO - Disk - Read: 2369442.65 MB, Write: 1238778.39 MB
2024-12-19 00:22:24,842 - INFO - CPU Usage: 23.4%
2024-12-19 00:22:24,842 - INFO - Memory Usage: 262.77 MB
2024-12-19 00:22:24,843 - INFO - Network - Sent: 874668.33 MB, Received: 439067.54 MB
2024-12-19 00:22:24,843 - INFO - Disk - Read: 2369442.68 MB, Write: 1238779.24 MB
2024-12-19 00:22:28,429 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:28,429 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:28,429 - INFO - Network - Sent: 874668.33 MB, Received: 439067.54 MB
2024-12-19 00:22:28,429 - INFO - Disk - Read: 2369442.73 MB, Write: 1238781.27 MB
2024-12-19 00:22:30,865 - INFO - CPU Usage: 25.0%
2024-12-19 00:22:30,865 - INFO - Memory Usage: 263.06 MB
2024-12-19 00:22:30,865 - INFO - Network - Sent: 874668.33 MB, Received: 439067.54 MB
2024-12-19 00:22:30,865 - INFO - Disk - Read: 2369442.79 MB, Write: 1238781.86 MB
2024-12-19 00:22:34,450 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:34,450 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:34,450 - INFO - Network - Sent: 874668.34 MB, Received: 439067.54 MB
2024-12-19 00:22:34,450 - INFO - Disk - Read: 2369443.16 MB, Write: 1238782.03 MB
2024-12-19 00:22:36,886 - INFO - CPU Usage: 31.2%
2024-12-19 00:22:36,887 - INFO - Memory Usage: 263.07 MB
2024-12-19 00:22:36,887 - INFO - Network - Sent: 874668.34 MB, Received: 439067.54 MB
2024-12-19 00:22:36,887 - INFO - Disk - Read: 2369443.16 MB, Write: 1238782.29 MB
2024-12-19 00:22:40,471 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:40,471 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:40,471 - INFO - Network - Sent: 874668.35 MB, Received: 439067.54 MB
2024-12-19 00:22:40,471 - INFO - Disk - Read: 2369444.59 MB, Write: 1238785.27 MB
2024-12-19 00:22:42,907 - INFO - CPU Usage: 28.1%
2024-12-19 00:22:42,908 - INFO - Memory Usage: 263.10 MB
2024-12-19 00:22:42,908 - INFO - Network - Sent: 874668.35 MB, Received: 439067.54 MB
2024-12-19 00:22:42,908 - INFO - Disk - Read: 2369444.59 MB, Write: 1238785.67 MB
2024-12-19 00:22:46,502 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:46,502 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:46,502 - INFO - Network - Sent: 874668.35 MB, Received: 439067.54 MB
2024-12-19 00:22:46,502 - INFO - Disk - Read: 2369444.62 MB, Write: 1238786.90 MB
2024-12-19 00:22:48,929 - INFO - CPU Usage: 35.9%
2024-12-19 00:22:48,929 - INFO - Memory Usage: 263.16 MB
2024-12-19 00:22:48,929 - INFO - Network - Sent: 874668.35 MB, Received: 439067.54 MB
2024-12-19 00:22:48,929 - INFO - Disk - Read: 2369444.62 MB, Write: 1238787.18 MB
2024-12-19 00:22:52,525 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:52,525 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:52,525 - INFO - Network - Sent: 874668.36 MB, Received: 439067.55 MB
2024-12-19 00:22:52,525 - INFO - Disk - Read: 2369444.77 MB, Write: 1238788.22 MB
2024-12-19 00:22:54,950 - INFO - CPU Usage: 39.1%
2024-12-19 00:22:54,950 - INFO - Memory Usage: 263.23 MB
2024-12-19 00:22:54,950 - INFO - Network - Sent: 874668.36 MB, Received: 439067.55 MB
2024-12-19 00:22:54,950 - INFO - Disk - Read: 2369447.70 MB, Write: 1238788.98 MB
2024-12-19 00:22:58,548 - INFO - CPU Usage: 0.0%
2024-12-19 00:22:58,548 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:22:58,548 - INFO - Network - Sent: 874668.37 MB, Received: 439067.55 MB
2024-12-19 00:22:58,548 - INFO - Disk - Read: 2369448.00 MB, Write: 1238789.79 MB
2024-12-19 00:23:00,972 - INFO - CPU Usage: 29.7%
2024-12-19 00:23:00,972 - INFO - Memory Usage: 263.29 MB
2024-12-19 00:23:00,972 - INFO - Network - Sent: 874668.37 MB, Received: 439067.55 MB
2024-12-19 00:23:00,972 - INFO - Disk - Read: 2369448.24 MB, Write: 1238790.87 MB
2024-12-19 00:23:04,569 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:04,569 - INFO - Memory Usage: 100.96 MB
2024-12-19 00:23:04,569 - INFO - Network - Sent: 874668.38 MB, Received: 439067.57 MB
2024-12-19 00:23:04,569 - INFO - Disk - Read: 2369448.65 MB, Write: 1238792.39 MB
2024-12-19 00:23:06,997 - INFO - CPU Usage: 23.4%
2024-12-19 00:23:06,997 - INFO - Memory Usage: 263.36 MB
2024-12-19 00:23:06,997 - INFO - Network - Sent: 874668.40 MB, Received: 439067.59 MB
2024-12-19 00:23:06,998 - INFO - Disk - Read: 2369448.76 MB, Write: 1238793.18 MB
2024-12-19 00:23:10,592 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:10,592 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:23:10,592 - INFO - Network - Sent: 874668.41 MB, Received: 439067.59 MB
2024-12-19 00:23:10,592 - INFO - Disk - Read: 2369449.29 MB, Write: 1238795.03 MB
2024-12-19 00:23:13,019 - INFO - CPU Usage: 29.2%
2024-12-19 00:23:13,019 - INFO - Memory Usage: 263.34 MB
2024-12-19 00:23:13,019 - INFO - Network - Sent: 874668.42 MB, Received: 439067.59 MB
2024-12-19 00:23:13,019 - INFO - Disk - Read: 2369449.34 MB, Write: 1238796.09 MB
2024-12-19 00:23:16,614 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:16,614 - INFO - Memory Usage: 100.93 MB
2024-12-19 00:23:16,614 - INFO - Network - Sent: 874668.44 MB, Received: 439067.60 MB
2024-12-19 00:23:16,615 - INFO - Disk - Read: 2369449.37 MB, Write: 1238798.39 MB
2024-12-19 00:23:19,050 - INFO - CPU Usage: 26.6%
2024-12-19 00:23:19,050 - INFO - Memory Usage: 263.32 MB
2024-12-19 00:23:19,050 - INFO - Network - Sent: 874668.45 MB, Received: 439067.61 MB
2024-12-19 00:23:19,051 - INFO - Disk - Read: 2369449.47 MB, Write: 1238799.06 MB
2024-12-19 00:23:22,636 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:22,636 - INFO - Memory Usage: 100.93 MB
2024-12-19 00:23:22,636 - INFO - Network - Sent: 874668.45 MB, Received: 439067.61 MB
2024-12-19 00:23:22,636 - INFO - Disk - Read: 2369449.47 MB, Write: 1238799.83 MB
2024-12-19 00:23:25,078 - INFO - CPU Usage: 48.4%
2024-12-19 00:23:25,078 - INFO - Memory Usage: 263.42 MB
2024-12-19 00:23:25,078 - INFO - Network - Sent: 874668.45 MB, Received: 439067.62 MB
2024-12-19 00:23:25,079 - INFO - Disk - Read: 2369449.53 MB, Write: 1238800.04 MB
2024-12-19 00:23:28,657 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:28,657 - INFO - Memory Usage: 100.93 MB
2024-12-19 00:23:28,657 - INFO - Network - Sent: 874668.46 MB, Received: 439067.62 MB
2024-12-19 00:23:28,657 - INFO - Disk - Read: 2369449.55 MB, Write: 1238801.05 MB
2024-12-19 00:23:31,099 - INFO - CPU Usage: 40.6%
2024-12-19 00:23:31,099 - INFO - Memory Usage: 263.36 MB
2024-12-19 00:23:31,099 - INFO - Network - Sent: 874668.47 MB, Received: 439067.64 MB
2024-12-19 00:23:31,099 - INFO - Disk - Read: 2369450.56 MB, Write: 1238801.79 MB
2024-12-19 00:23:34,678 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:34,678 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:23:34,678 - INFO - Network - Sent: 874668.47 MB, Received: 439067.65 MB
2024-12-19 00:23:34,678 - INFO - Disk - Read: 2369450.56 MB, Write: 1238802.75 MB
2024-12-19 00:23:37,120 - INFO - CPU Usage: 31.2%
2024-12-19 00:23:37,120 - INFO - Memory Usage: 263.49 MB
2024-12-19 00:23:37,121 - INFO - Network - Sent: 874668.47 MB, Received: 439067.65 MB
2024-12-19 00:23:37,121 - INFO - Disk - Read: 2369450.58 MB, Write: 1238803.89 MB
2024-12-19 00:23:40,708 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:40,708 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:23:40,708 - INFO - Network - Sent: 874668.47 MB, Received: 439067.65 MB
2024-12-19 00:23:40,708 - INFO - Disk - Read: 2369450.61 MB, Write: 1238804.31 MB
2024-12-19 00:23:43,141 - INFO - CPU Usage: 46.9%
2024-12-19 00:23:43,141 - INFO - Memory Usage: 263.44 MB
2024-12-19 00:23:43,142 - INFO - Network - Sent: 874668.48 MB, Received: 439067.66 MB
2024-12-19 00:23:43,142 - INFO - Disk - Read: 2369451.41 MB, Write: 1238804.62 MB
2024-12-19 00:23:46,728 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:46,728 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:23:46,728 - INFO - Network - Sent: 874668.49 MB, Received: 439067.69 MB
2024-12-19 00:23:46,728 - INFO - Disk - Read: 2369451.75 MB, Write: 1238805.29 MB
2024-12-19 00:23:49,163 - INFO - CPU Usage: 37.5%
2024-12-19 00:23:49,164 - INFO - Memory Usage: 263.53 MB
2024-12-19 00:23:49,164 - INFO - Network - Sent: 874668.50 MB, Received: 439067.69 MB
2024-12-19 00:23:49,164 - INFO - Disk - Read: 2369451.75 MB, Write: 1238805.55 MB
2024-12-19 00:23:52,752 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:52,752 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:23:52,752 - INFO - Network - Sent: 874668.50 MB, Received: 439067.70 MB
2024-12-19 00:23:52,752 - INFO - Disk - Read: 2369451.94 MB, Write: 1238807.01 MB
2024-12-19 00:23:55,183 - INFO - CPU Usage: 42.2%
2024-12-19 00:23:55,184 - INFO - Memory Usage: 263.47 MB
2024-12-19 00:23:55,184 - INFO - Network - Sent: 874668.50 MB, Received: 439067.70 MB
2024-12-19 00:23:55,184 - INFO - Disk - Read: 2369452.01 MB, Write: 1238807.51 MB
2024-12-19 00:23:58,773 - INFO - CPU Usage: 0.0%
2024-12-19 00:23:58,773 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:23:58,773 - INFO - Network - Sent: 874668.51 MB, Received: 439067.70 MB
2024-12-19 00:23:58,773 - INFO - Disk - Read: 2369452.18 MB, Write: 1238808.06 MB
2024-12-19 00:24:01,206 - INFO - CPU Usage: 37.5%
2024-12-19 00:24:01,206 - INFO - Memory Usage: 263.70 MB
2024-12-19 00:24:01,207 - INFO - Network - Sent: 874668.51 MB, Received: 439067.70 MB
2024-12-19 00:24:01,207 - INFO - Disk - Read: 2369452.18 MB, Write: 1238808.59 MB
2024-12-19 00:24:04,795 - INFO - CPU Usage: 0.0%
2024-12-19 00:24:04,796 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:24:04,796 - INFO - Network - Sent: 874668.51 MB, Received: 439067.70 MB
2024-12-19 00:24:04,796 - INFO - Disk - Read: 2369452.86 MB, Write: 1238808.72 MB
2024-12-19 00:24:07,228 - INFO - CPU Usage: 15.6%
2024-12-19 00:24:07,228 - INFO - Memory Usage: 263.67 MB
2024-12-19 00:24:07,229 - INFO - Network - Sent: 874668.51 MB, Received: 439067.70 MB
2024-12-19 00:24:07,229 - INFO - Disk - Read: 2369453.19 MB, Write: 1238808.94 MB
2024-12-19 00:24:10,817 - INFO - CPU Usage: 0.0%
2024-12-19 00:24:10,817 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:24:10,817 - INFO - Network - Sent: 874668.52 MB, Received: 439067.70 MB
2024-12-19 00:24:10,817 - INFO - Disk - Read: 2369453.35 MB, Write: 1238813.24 MB
2024-12-19 00:24:13,251 - INFO - CPU Usage: 39.1%
2024-12-19 00:24:13,251 - INFO - Memory Usage: 263.86 MB
2024-12-19 00:24:13,252 - INFO - Network - Sent: 874668.53 MB, Received: 439067.71 MB
2024-12-19 00:24:13,252 - INFO - Disk - Read: 2369453.35 MB, Write: 1238813.48 MB
2024-12-19 00:24:16,838 - INFO - CPU Usage: 0.0%
2024-12-19 00:24:16,838 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:24:16,838 - INFO - Network - Sent: 874668.53 MB, Received: 439067.71 MB
2024-12-19 00:24:16,838 - INFO - Disk - Read: 2369453.42 MB, Write: 1238813.99 MB
2024-12-19 00:24:19,274 - INFO - CPU Usage: 26.6%
2024-12-19 00:24:19,274 - INFO - Memory Usage: 263.86 MB
2024-12-19 00:24:19,274 - INFO - Network - Sent: 874668.54 MB, Received: 439067.71 MB
2024-12-19 00:24:19,274 - INFO - Disk - Read: 2369453.43 MB, Write: 1238814.25 MB
2024-12-19 00:24:22,860 - INFO - CPU Usage: 0.0%
2024-12-19 00:24:22,860 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:24:22,860 - INFO - Network - Sent: 874668.55 MB, Received: 439067.73 MB
2024-12-19 00:24:22,860 - INFO - Disk - Read: 2369453.82 MB, Write: 1238816.14 MB
2024-12-19 00:24:25,295 - INFO - CPU Usage: 54.7%
2024-12-19 00:24:25,295 - INFO - Memory Usage: 263.88 MB
2024-12-19 00:24:25,295 - INFO - Network - Sent: 874668.56 MB, Received: 439067.73 MB
2024-12-19 00:24:25,295 - INFO - Disk - Read: 2369454.10 MB, Write: 1238816.34 MB
2024-12-19 00:24:28,882 - INFO - CPU Usage: 0.0%
2024-12-19 00:24:28,882 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:24:28,883 - INFO - Network - Sent: 874668.56 MB, Received: 439067.73 MB
2024-12-19 00:24:28,883 - INFO - Disk - Read: 2369454.72 MB, Write: 1238817.59 MB
2024-12-19 00:24:31,316 - INFO - CPU Usage: 29.7%
2024-12-19 00:24:31,316 - INFO - Memory Usage: 263.96 MB
2024-12-19 00:24:31,317 - INFO - Network - Sent: 874668.57 MB, Received: 439067.74 MB
2024-12-19 00:24:31,317 - INFO - Disk - Read: 2369454.72 MB, Write: 1238818.38 MB
2024-12-19 00:24:34,907 - INFO - CPU Usage: 0.0%
2024-12-19 00:24:34,907 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:24:34,908 - INFO - Network - Sent: 874668.58 MB, Received: 439067.74 MB
2024-12-19 00:24:34,908 - INFO - Disk - Read: 2369454.77 MB, Write: 1238819.48 MB
2024-12-19 00:24:36,039 - INFO - Video feed has ended at Thu Dec 19 00:24:35 2024
2024-12-19 00:24:37,338 - INFO - CPU Usage: 6.2%
2024-12-19 00:24:37,338 - INFO - Memory Usage: 132.93 MB
2024-12-19 00:24:37,338 - INFO - Network - Sent: 874668.59 MB, Received: 439067.75 MB
2024-12-19 00:24:37,338 - INFO - Disk - Read: 2369454.90 MB, Write: 1238822.27 MB
2024-12-19 00:24:40,929 - INFO - CPU Usage: 0.0%
2024-12-19 00:24:40,929 - INFO - Memory Usage: 100.95 MB
2024-12-19 00:24:40,929 - INFO - Network - Sent: 874668.60 MB, Received: 439067.76 MB
2024-12-19 00:24:40,929 - INFO - Disk - Read: 2369458.39 MB, Write: 1238825.84 MB
2024-12-19 00:24:43,361 - INFO - CPU Usage: 7.8%
2024-12-19 00:24:43,361 - INFO - Memory Usage: 125.49 MB
2024-12-19 00:24:43,361 - INFO - Network - Sent: 874668.61 MB, Received: 439067.76 MB
2024-12-19 00:24:43,361 - INFO - Disk - Read: 2369458.53 MB, Write: 1238827.78 MB
...
"""  # 将完整的日志数据替换在这里



# 2024-12-19 00:21:22,167 - INFO - Network - Sent: 874668.16 MB, Received: 439067.46 MB
# 2024-12-19 00:21:22,167 - INFO - Disk - Read: 2369435.60 MB, Write: 1238180.93 MB

# 用于存储解析后的数据
cpu_usage = []
memory_usage = []
network_sent = []
network_received = []
disk_read = []
disk_write = []

# 正则表达式用于匹配日志中的数值
cpu_pattern = re.compile(r"CPU Usage: (\d+\.\d+)%")
memory_pattern = re.compile(r"Memory Usage: (\d+\.\d+) MB")
network_sent_pattern = re.compile(r"Sent: (\d+\.\d+) MB")
network_received_pattern = re.compile(r"Received: (\d+\.\d+) MB")
disk_read_pattern = re.compile(r"Read: (\d+\.\d+) MB")
disk_write_pattern = re.compile(r"Write: (\d+\.\d+) MB")

# 解析日志数据
for line in log_data.strip().split('\n'):
    if "CPU Usage" in line:
        cpu_usage.append(float(cpu_pattern.search(line).group(1)))
    elif "Memory Usage" in line:
        memory_usage.append(float(memory_pattern.search(line).group(1)))
    elif "Sent" in line:
        network_sent.append(float(network_sent_pattern.search(line).group(1))-874668)
        network_received.append(float(network_received_pattern.search(line).group(1)) - 439067)
    elif "Read" in line:
        disk_read.append(float(disk_read_pattern.search(line).group(1)) - 2369435)
        disk_write.append(float(disk_write_pattern.search(line).group(1)) - 1238180)

# 绘制图表
plt.figure(figsize=(14, 10))

plt.subplot(2, 3, 1)
plt.plot(cpu_usage, label='CPU Usage')
plt.title('CPU Usage Over Time')
plt.xlabel('Time')
plt.ylabel('Percentage')
plt.legend()

plt.subplot(2, 3, 2)
plt.plot(memory_usage, label='Memory Usage', color='orange')
plt.title('Memory Usage Over Time')
plt.xlabel('Time')
plt.ylabel('MB')
plt.legend()

plt.subplot(2, 3, 3)
plt.plot(network_sent, label='Sent', color='blue')
plt.plot(network_received, label='Received', color='green')
plt.title('Network Usage Over Time')
plt.xlabel('Time')
plt.ylabel('MB')
plt.legend()

plt.subplot(2, 3, 4)
plt.plot(disk_read, label='Disk Read', color='red')
plt.plot(disk_write, label='Disk Write', color='purple')
plt.title('Disk Usage Over Time')
plt.xlabel('Time')
plt.ylabel('MB')
plt.legend()

plt.tight_layout()
plt.show()