#!/usr/bin/env python3
"""
Capture raw screenshots from the running Vantag app in the iOS Simulator.

Uses Quartz CGEvents to tap on the simulator window and navigate between tabs,
then xcrun simctl to capture device-level screenshots.

Prerequisites:
- iOS Simulator must be booted with the app running
- pip3 install pyobjc-framework-Quartz

Usage:
    python3 scripts/capture_raw_screenshots.py
"""

import subprocess
import time
import os
import Quartz


def find_simulator_window():
    """Find the Simulator window bounds."""
    options = Quartz.kCGWindowListOptionOnScreenOnly
    window_list = Quartz.CGWindowListCopyWindowInfo(options, Quartz.kCGNullWindowID)

    for w in window_list:
        owner = w.get('kCGWindowOwnerName', '')
        if 'Simulator' in owner:
            bounds = w.get('kCGWindowBounds', {})
            return {
                'x': bounds.get('X', 0),
                'y': bounds.get('Y', 0),
                'width': bounds.get('Width', 0),
                'height': bounds.get('Height', 0),
            }
    raise RuntimeError("Simulator window not found! Make sure the simulator is running.")


def bring_simulator_to_front():
    """Bring the Simulator app to the foreground."""
    subprocess.run([
        'osascript', '-e',
        'tell application "Simulator" to activate'
    ])
    time.sleep(0.5)


def tap(x, y):
    """Send a mouse click at absolute screen coordinates using CGEvents."""
    point = Quartz.CGPointMake(x, y)

    # Mouse down
    event_down = Quartz.CGEventCreateMouseEvent(
        None,
        Quartz.kCGEventLeftMouseDown,
        point,
        Quartz.kCGMouseButtonLeft
    )
    Quartz.CGEventPost(Quartz.kCGHIDEventTap, event_down)
    time.sleep(0.05)

    # Mouse up
    event_up = Quartz.CGEventCreateMouseEvent(
        None,
        Quartz.kCGEventLeftMouseUp,
        point,
        Quartz.kCGMouseButtonLeft
    )
    Quartz.CGEventPost(Quartz.kCGHIDEventTap, event_up)
    time.sleep(0.3)


def take_screenshot(name, output_dir):
    """Take a screenshot using xcrun simctl."""
    path = os.path.join(output_dir, f"{name}.png")
    result = subprocess.run(
        ['xcrun', 'simctl', 'io', 'booted', 'screenshot', path],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        size = os.path.getsize(path)
        print(f"  Saved: {path} ({size // 1024} KB)")
    else:
        print(f"  ERROR: {result.stderr}")
    return path


def main():
    output_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'docs', 'screenshots')
    os.makedirs(output_dir, exist_ok=True)

    # Find simulator window
    win = find_simulator_window()
    print(f"Simulator window: x={win['x']}, y={win['y']}, w={win['width']}, h={win['height']}")

    # Calculate tap coordinates relative to window
    # Window dimensions: 384 x 833 (at this zoom level)
    # The device content area excludes the simulator chrome (title bar, etc.)
    # Bottom nav bar is approximately at the bottom ~70px of the window
    wx = win['x']
    wy = win['y']
    ww = win['width']
    wh = win['height']

    # Tab bar positions (5 items: Home, Analysis, +, Dreams, Settings)
    # Y position of tab bar icons: roughly 50px from bottom of window
    tab_y = wy + wh - 35
    tab_positions = {
        'home':     wx + ww * 0.1,   # ~10% from left
        'analysis': wx + ww * 0.3,   # ~30% from left
        'add':      wx + ww * 0.5,   # center
        'dreams':   wx + ww * 0.7,   # ~70% from left
        'settings': wx + ww * 0.9,   # ~90% from left
    }

    # Bring simulator to front
    bring_simulator_to_front()
    time.sleep(1)

    # === Screenshot 1: Home Screen ===
    print("\n[1/6] Home Screen")
    tap(tab_positions['home'], tab_y)
    time.sleep(1.5)
    take_screenshot('raw_1_home', output_dir)

    # === Screenshot 2: Reports/Analysis Screen ===
    print("\n[2/6] Reports/Analysis Screen")
    tap(tab_positions['analysis'], tab_y)
    time.sleep(2)
    take_screenshot('raw_2_reports', output_dir)

    # === Screenshot 3: Add Expense Sheet ===
    print("\n[3/6] Add Expense Sheet")
    tap(tab_positions['home'], tab_y)  # Go home first
    time.sleep(1)
    tap(tab_positions['add'], tab_y)   # Tap the + button
    time.sleep(2)
    take_screenshot('raw_3_add_expense', output_dir)

    # Close the add expense sheet - tap outside (top area)
    tap(wx + ww / 2, wy + 100)
    time.sleep(1)

    # === Screenshot 4: Achievements Screen ===
    # First navigate to Settings, then tap on Badges/Rozetler row
    print("\n[4/6] Achievements Screen (via Settings > Badges)")
    tap(tab_positions['settings'], tab_y)
    time.sleep(2)

    # Badges/Rozetler is typically in the middle section of settings
    # Let's scroll down a bit first and then tap on the Badges row
    # Settings screen layout: the badges row is usually around y=55-65% down
    badges_y = wy + wh * 0.55
    tap(wx + ww / 2, badges_y)
    time.sleep(2)
    take_screenshot('raw_4_achievements', output_dir)

    # Go back from achievements to settings
    # The back button is in the top-left corner
    tap(wx + 30, wy + 60)
    time.sleep(1)

    # === Screenshot 5: Dreams/Pursuits Screen ===
    print("\n[5/6] Dreams/Pursuits Screen")
    tap(tab_positions['dreams'], tab_y)
    time.sleep(2)
    take_screenshot('raw_5_dreams', output_dir)

    # === Screenshot 6: Settings Screen ===
    print("\n[6/6] Settings Screen")
    tap(tab_positions['settings'], tab_y)
    time.sleep(2)
    take_screenshot('raw_6_settings', output_dir)

    print("\n=== All 6 screenshots captured! ===")
    print(f"Output directory: {output_dir}")


if __name__ == '__main__':
    main()
