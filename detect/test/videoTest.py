import cv2
import time
import requests
import threading
import psutil

VIDEO_FEED_URL = "http://127.0.0.1:5000/video_feed?index=0"

def fetch_video_stream():
    """Fetch video stream and display."""
    cap = cv2.VideoCapture(VIDEO_FEED_URL)
    frame_count = 0
    start_time = time.time()

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Failed to fetch frame.")
            break

        frame_count += 1
        # Optionally display the frame
        cv2.imshow("Video Stream", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    end_time = time.time()
    print(f"Fetched {frame_count} frames in {end_time - start_time:.2f} seconds.")
    cap.release()
    cv2.destroyAllWindows()

def monitor_resources(duration=10, interval=1):
    """Monitor system resource usage during video stream."""
    process = psutil.Process()  # Current process
    process_id = process.pid  # Get the current process ID
    print(f"Monitoring resources for {duration} seconds... (Process ID: {process_id})")
    for _ in range(int(duration / interval)):
        cpu_usage = process.cpu_percent()
        mem_usage = process.memory_info().rss / (1024 ** 2)  # Memory in MB
        print(f"CPU Usage: {cpu_usage:.2f}%, Memory Usage: {mem_usage:.2f} MB")
        time.sleep(interval)

if __name__ == "__main__":
    # Start resource monitoring in a separate thread
    monitor_thread = threading.Thread(target=monitor_resources, args=(60, 1))
    monitor_thread.start()

    # Fetch video stream
    fetch_video_stream()

    # Wait for monitoring to finish
    monitor_thread.join()
