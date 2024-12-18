import os
import time
import psutil
import requests
import threading

# Flask 服务的进程名称或 PID
FLASK_PROCESS_NAME = "python"  # 假设 Flask 用 Python 启动
FLASK_URL = "http://127.0.0.1:5000"

def get_flask_process():
    """获取 Flask 服务的进程信息"""
    for proc in psutil.process_iter(attrs=['pid', 'name', 'cmdline']):
        if FLASK_PROCESS_NAME in proc.info['name']:
            return proc
    return None

def monitor_resource_usage(proc, duration=10, interval=1):
    """监控指定进程的 CPU 和内存使用情况"""
    if not proc:
        print("Flask process not found.")
        return
    
    print(f"Monitoring Flask process (PID={proc.pid}) for {duration} seconds...")
    for _ in range(int(duration / interval)):
        cpu_usage = proc.cpu_percent()  # CPU 使用率（%）
        mem_usage = proc.memory_info().rss / (1024 ** 2)  # 内存使用量（MB）
        print(f"CPU: {cpu_usage:.2f}%, Memory: {mem_usage:.2f} MB")
        time.sleep(interval)

def simulate_requests():
    """模拟请求以加载 Flask 服务"""
    endpoints = [ "/video_feed?index=0", "/posture_times", "/session_record"]
    for route in endpoints:
        try:
            response = requests.get(f"{FLASK_URL}{route}")
            print(f"Request to {route} returned {response.status_code}")
        except Exception as e:
            print(f"Error accessing {route}: {e}")

if __name__ == "__main__":
    # 获取 Flask 服务的进程
    flask_process = get_flask_process()

    # 在后台监控资源占用
    monitor_thread = threading.Thread(target=monitor_resource_usage, args=(flask_process, 20, 2))
    monitor_thread.start()

    # 模拟并发请求
    simulate_requests()

    # 等待监控线程结束
    monitor_thread.join()
