#!/usr/bin/env python3
"""
Vantag App Store Screenshot Generator (Playwright Edition)

Generates 6 App Store screenshot frames as HTML pages,
then renders each at 1320×2868 to PNG using Playwright headless Chromium.

Usage:
    pip install playwright --break-system-packages
    python -m playwright install chromium
    python3 scripts/generate_screenshots.py

Output: docs/screenshots/appstore_1_hook.png … appstore_6_ai_chat.png
        docs/screenshots/frames/frame_*.html  (intermediate HTML)
"""

import os
import sys
import asyncio

W, H = 1320, 2868
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(BASE_DIR, "docs", "screenshots")
FRAMES_DIR = os.path.join(OUT_DIR, "frames")

# ═══════════════════════════════════════════════════════════════════════════
# SHARED CSS — Vantag Design System v2.0
# ═══════════════════════════════════════════════════════════════════════════

COMMON_CSS = f"""
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
html, body {{
    width: {W}px; height: {H}px;
    overflow: hidden;
    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display',
                 'SF Pro Text', system-ui, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
}}
body {{
    background: linear-gradient(175deg, #3D2E5C 0%, #2A1D47 30%, #1A1128 100%);
    position: relative;
    color: #F5F5F7;
}}

/* ── Background effects ── */
.bg-glow {{
    position: absolute;
    top: -300px; left: 50%;
    transform: translateX(-50%);
    width: 1000px; height: 1000px;
    border-radius: 50%;
    background: radial-gradient(circle,
        rgba(95,74,139,0.5) 0%,
        rgba(95,74,139,0.2) 40%,
        transparent 70%);
    pointer-events: none;
}}
.bg-glow-bottom {{
    position: absolute;
    bottom: -400px; left: 50%;
    transform: translateX(-50%);
    width: 1200px; height: 800px;
    border-radius: 50%;
    background: radial-gradient(circle,
        rgba(34,211,238,0.08) 0%,
        transparent 60%);
    pointer-events: none;
}}

/* ── Headlines ── */
.headline-section {{
    position: absolute;
    top: 130px; left: 0; right: 0;
    text-align: center;
    z-index: 5;
    padding: 0 60px;
}}
.headline {{
    font-size: 74px;
    font-weight: 800;
    color: #FEFACD;
    line-height: 1.12;
    letter-spacing: -1.5px;
    text-shadow: 0 2px 40px rgba(254,250,205,0.15);
}}
.subtitle {{
    font-size: 36px;
    font-weight: 400;
    color: rgba(245,245,247,0.55);
    margin-top: 22px;
    letter-spacing: -0.3px;
}}

/* ── Phone Mockup ── */
.phone-container {{
    position: absolute;
    top: 540px; left: 50%;
    transform: translateX(-50%);
    width: 1080px;
    height: {H - 540 - 50}px;
    z-index: 3;
}}
.phone-frame {{
    width: 100%;  height: 100%;
    border-radius: 62px;
    border: 5px solid rgba(120,90,180,0.35);
    overflow: hidden;
    position: relative;
    background: #08060E;
    box-shadow:
        0 60px 120px rgba(0,0,0,0.6),
        0 0 0 1px rgba(255,255,255,0.04),
        0 0 160px rgba(95,74,139,0.12),
        inset 0 1px 0 rgba(255,255,255,0.06);
}}
.notch {{
    position: absolute;
    top: 16px; left: 50%;
    transform: translateX(-50%);
    width: 190px; height: 50px;
    border-radius: 25px;
    background: #000;
    z-index: 20;
    box-shadow: 0 0 0 2px rgba(30,20,40,0.8);
}}
.screen {{
    position: absolute;
    top: 0; left: 0; right: 0; bottom: 0;
    background: #0A0A0F;
    overflow: hidden;
}}
.home-bar {{
    position: absolute;
    bottom: 14px; left: 50%;
    transform: translateX(-50%);
    width: 180px; height: 7px;
    border-radius: 4px;
    background: rgba(245,245,247,0.25);
    z-index: 25;
}}

/* ── Status bar ── */
.status-bar {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 30px 0;
    height: 82px;
    font-size: 26px;
    font-weight: 600;
    color: #F5F5F7;
    position: relative;
    z-index: 15;
}}
.status-icons {{
    display: flex; gap: 8px; align-items: center;
    font-size: 22px;
}}
.status-icons .signal {{ letter-spacing: -2px; font-size: 14px; }}
.status-icons .battery {{
    width: 40px; height: 18px;
    border: 2px solid rgba(245,245,247,0.8);
    border-radius: 4px;
    position: relative;
    display: inline-block;
}}
.status-icons .battery::after {{
    content: '';
    position: absolute;
    right: -5px; top: 4px;
    width: 3px; height: 8px;
    border-radius: 0 2px 2px 0;
    background: rgba(245,245,247,0.8);
}}
.status-icons .battery-fill {{
    position: absolute;
    top: 2px; left: 2px; bottom: 2px;
    width: 70%;
    background: #4ADE80;
    border-radius: 2px;
}}

/* ── Tab bar ── */
.tab-bar {{
    position: absolute;
    bottom: 0; left: 0; right: 0;
    height: 110px;
    background: linear-gradient(180deg,
        rgba(10,10,15,0.0) 0%,
        rgba(10,10,15,0.95) 30%,
        #0A0A0F 100%);
    display: flex;
    align-items: center;
    justify-content: space-around;
    padding: 0 16px 30px;
    z-index: 15;
}}
.tab {{
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    opacity: 0.45;
    font-size: 18px;
}}
.tab.active {{ opacity: 1; }}
.tab-icon {{ font-size: 28px; }}
.tab-label {{ font-size: 17px; font-weight: 500; }}
.tab-add {{
    width: 64px; height: 64px;
    border-radius: 50%;
    background: linear-gradient(135deg, #5F4A8B, #7B62A8);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 36px;
    font-weight: 300;
    color: white;
    box-shadow: 0 4px 20px rgba(95,74,139,0.5);
    margin-top: -20px;
}}
"""

# ═══════════════════════════════════════════════════════════════════════════
# STATUS BAR HTML (reusable)
# ═══════════════════════════════════════════════════════════════════════════

STATUS_BAR = """
<div class="status-bar">
    <span>16:10</span>
    <div class="status-icons">
        <span class="signal">●●●●</span>
        <svg width="24" height="20" viewBox="0 0 24 20" fill="none">
            <path d="M12 17.5l-8.5-8.5C5.5 6.5 8.5 5 12 5s6.5 1.5 8.5 4l-8.5 8.5z"
                  fill="rgba(245,245,247,0.85)"/>
        </svg>
        <span class="battery">
            <span class="battery-fill"></span>
        </span>
    </div>
</div>
"""

TAB_BAR = """
<div class="tab-bar">
    <div class="tab active">
        <div class="tab-icon">🏠</div>
        <div class="tab-label">Ana Sayfa</div>
    </div>
    <div class="tab">
        <div class="tab-icon">📊</div>
        <div class="tab-label">Analiz</div>
    </div>
    <div class="tab-add">+</div>
    <div class="tab">
        <div class="tab-icon">⭐</div>
        <div class="tab-label">Hayaller</div>
    </div>
    <div class="tab">
        <div class="tab-icon">⚙️</div>
        <div class="tab-label">Ayarlar</div>
    </div>
</div>
"""


def html_page(body: str, extra_css: str = "") -> str:
    """Wrap body content in a complete HTML document."""
    return f"""<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width={W}, height={H}">
<style>
{COMMON_CSS}
{extra_css}
</style>
</head>
<body>
<div class="bg-glow"></div>
<div class="bg-glow-bottom"></div>
{body}
</body>
</html>"""


# ═══════════════════════════════════════════════════════════════════════════
# FRAME 1 — HOOK  (no phone, centered text)
# ═══════════════════════════════════════════════════════════════════════════

def frame_1_hook() -> str:
    css = """
    .hook-wrap {
        position: absolute;
        top: 0; left: 0; right: 0; bottom: 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        z-index: 5;
    }
    .hook-emoji {
        font-size: 160px;
        margin-bottom: 40px;
        filter: drop-shadow(0 8px 30px rgba(0,0,0,0.3));
    }
    .hook-main {
        text-align: center;
    }
    .hook-line {
        font-size: 96px;
        font-weight: 800;
        color: #FEFACD;
        letter-spacing: -2px;
        line-height: 1.15;
        text-shadow: 0 4px 50px rgba(254,250,205,0.2);
    }
    .hook-equals {
        font-size: 72px;
        font-weight: 300;
        color: rgba(254,250,205,0.45);
        margin: 20px 0;
        display: block;
    }
    .hook-tagline {
        font-size: 38px;
        font-weight: 400;
        color: rgba(245,245,247,0.45);
        margin-top: 50px;
        letter-spacing: -0.3px;
    }
    .logo-section {
        position: absolute;
        bottom: 120px; left: 0; right: 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 12px;
        z-index: 5;
    }
    .logo-mark {
        width: 80px; height: 80px;
        border-radius: 20px;
        background: linear-gradient(135deg, #5F4A8B, #7B62A8);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 40px;
        font-weight: 800;
        color: #FEFACD;
        box-shadow: 0 8px 30px rgba(95,74,139,0.4);
    }
    .logo-name {
        font-size: 32px;
        font-weight: 700;
        color: rgba(245,245,247,0.5);
        letter-spacing: 4px;
        text-transform: lowercase;
    }
    """
    body = """
    <div class="hook-wrap">
        <div class="hook-emoji">☕</div>
        <div class="hook-main">
            <div class="hook-line">200₺ kahve</div>
            <span class="hook-equals">=</span>
            <div class="hook-line">⏱ 45 dk mesai</div>
        </div>
        <div class="hook-tagline">Gerçek maliyet bu.</div>
    </div>
    <div class="logo-section">
        <div class="logo-mark">V</div>
        <div class="logo-name">vantag</div>
    </div>
    """
    return html_page(body, css)


# ═══════════════════════════════════════════════════════════════════════════
# FRAME 2 — HOME SCREEN
# ═══════════════════════════════════════════════════════════════════════════

def frame_2_home() -> str:
    css = """
    .home-content { padding: 88px 28px 120px; }
    .greeting-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
    }
    .avatar {
        width: 56px; height: 56px;
        border-radius: 50%;
        background: linear-gradient(135deg, #3D2E5C, #5F4A8B);
        border: 2px solid rgba(255,255,255,0.1);
        display: flex; align-items: center; justify-content: center;
        font-size: 24px;
    }
    .streak-badge {
        background: rgba(239,68,68,0.15);
        border: 1px solid rgba(239,68,68,0.3);
        border-radius: 20px;
        padding: 8px 16px;
        font-size: 22px;
        font-weight: 600;
        color: #F87171;
    }
    .greeting-text {
        font-size: 26px;
        color: #8B8B9E;
        margin: 14px 0 4px;
    }
    .month-header {
        font-size: 44px;
        font-weight: 800;
        color: #F5F5F7;
        letter-spacing: -0.5px;
        margin-bottom: 24px;
    }
    /* Habit CTA */
    .habit-cta {
        background: linear-gradient(135deg, rgba(95,74,139,0.25), rgba(95,74,139,0.1));
        border: 1px solid rgba(95,74,139,0.35);
        border-radius: 20px;
        padding: 22px 26px;
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 28px;
    }
    .habit-icon {
        width: 48px; height: 48px;
        border-radius: 14px;
        background: linear-gradient(135deg, #5F4A8B, #7B62A8);
        display: flex; align-items: center; justify-content: center;
        font-size: 26px;
    }
    .habit-text { flex: 1; }
    .habit-title {
        font-size: 24px; font-weight: 600;
        color: #F5F5F7;
    }
    .habit-sub {
        font-size: 20px; color: #8B8B9E;
        margin-top: 2px;
    }
    .habit-arrow { font-size: 28px; color: #8B8B9E; }
    /* Hero card */
    .hero-card {
        background: linear-gradient(145deg, rgba(95,74,139,0.35), rgba(60,45,92,0.2));
        border: 1px solid rgba(95,74,139,0.3);
        border-radius: 28px;
        padding: 28px;
        text-align: center;
        margin-bottom: 28px;
        position: relative;
        overflow: hidden;
    }
    .hero-card::before {
        content: '';
        position: absolute;
        top: -60px; left: 50%;
        transform: translateX(-50%);
        width: 300px; height: 300px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(95,74,139,0.25), transparent 70%);
    }
    .hero-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(255,255,255,0.06);
        border: 1px solid rgba(255,255,255,0.1);
        border-radius: 12px;
        padding: 8px 16px;
        font-size: 20px;
        font-weight: 600;
        color: #FEFACD;
        margin-bottom: 28px;
        position: relative;
    }
    .hero-ring {
        width: 120px; height: 120px;
        border-radius: 50%;
        border: 5px solid rgba(95,74,139,0.25);
        margin: 0 auto 24px;
        position: relative;
        display: flex; align-items: center; justify-content: center;
    }
    .hero-ring::after {
        content: '';
        position: absolute;
        top: -5px; left: -5px; right: -5px; bottom: -5px;
        border-radius: 50%;
        border: 5px solid transparent;
        border-top-color: #5F4A8B;
        border-right-color: #5F4A8B;
    }
    .hero-ring-icon { font-size: 40px; }
    .hero-numbers {
        display: flex;
        justify-content: center;
        gap: 60px;
        position: relative;
    }
    .hero-num-group { text-align: center; }
    .hero-num {
        font-size: 80px;
        font-weight: 800;
        color: #F5F5F7;
        line-height: 1;
    }
    .hero-label {
        font-size: 22px;
        font-weight: 600;
        color: #8B8B9E;
        letter-spacing: 2px;
        margin-top: 6px;
    }
    .hero-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 22px;
        font-size: 21px;
        color: #8B8B9E;
    }
    .hero-budget-tag {
        color: #FEFACD;
        font-weight: 600;
    }
    .budget-dots {
        display: flex;
        justify-content: center;
        gap: 8px;
        margin-top: 14px;
    }
    .budget-dot {
        width: 10px; height: 10px;
        border-radius: 50%;
        background: #4ADE80;
    }
    /* Expense list */
    .section-title {
        font-size: 28px;
        font-weight: 700;
        color: #F5F5F7;
        margin: 20px 0 18px;
    }
    .expense-item {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 20px;
        background: rgba(19,19,26,0.6);
        border: 1px solid rgba(255,255,255,0.04);
        border-radius: 18px;
        margin-bottom: 12px;
    }
    .expense-icon {
        width: 50px; height: 50px;
        border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px;
    }
    .expense-info { flex: 1; }
    .expense-amount {
        font-size: 26px; font-weight: 700; color: #F5F5F7;
    }
    .expense-meta {
        font-size: 20px; color: #6B6B7E; margin-top: 3px;
    }
    .expense-right { text-align: right; }
    .expense-date {
        font-size: 20px; color: #6B6B7E;
    }
    .expense-check {
        width: 36px; height: 36px;
        border-radius: 50%;
        background: linear-gradient(135deg, #22D3EE, #06B6D4);
        display: flex; align-items: center; justify-content: center;
        font-size: 18px;
        margin-top: 6px;
    }
    """
    screen = f"""
    {STATUS_BAR}
    <div class="home-content">
        <div class="greeting-row">
            <div class="avatar">👤</div>
            <div class="streak-badge">🔥 2 gün</div>
        </div>
        <div class="greeting-text">İyi günler 👋</div>
        <div class="month-header">Şubat 2026</div>

        <div class="habit-cta">
            <div class="habit-icon">⚡</div>
            <div class="habit-text">
                <div class="habit-title">Alışkanlığın kaç gününü alıyor?</div>
                <div class="habit-sub">Hesapla ve şok ol →</div>
            </div>
            <div class="habit-arrow">›</div>
        </div>

        <div class="hero-card">
            <div class="hero-badge">⏰ ÇALIŞMA KARŞILIĞI</div>
            <div class="hero-ring">
                <div class="hero-ring-icon">💫</div>
            </div>
            <div class="hero-numbers">
                <div class="hero-num-group">
                    <div class="hero-num">7</div>
                    <div class="hero-label">SAAT</div>
                </div>
                <div class="hero-num-group">
                    <div class="hero-num">1</div>
                    <div class="hero-label">GÜN</div>
                </div>
            </div>
            <div class="hero-footer">
                <span>Bütçe Kullanımı</span>
                <span class="hero-budget-tag">%4</span>
            </div>
            <div class="budget-dots"><div class="budget-dot"></div></div>
        </div>

        <div class="section-title">Son Harcamalar</div>

        <div class="expense-item">
            <div class="expense-icon" style="background:rgba(248,113,113,0.12);border:1px solid rgba(248,113,113,0.25);">
                <span style="color:#F87171;">📄</span>
            </div>
            <div class="expense-info">
                <div class="expense-amount">1.000 ₺</div>
                <div class="expense-meta">Faturalar · 2.9 saat</div>
            </div>
            <div class="expense-right">
                <div class="expense-date">8 Şub 2026</div>
                <div class="expense-check">✓</div>
            </div>
        </div>

        <div class="expense-item">
            <div class="expense-icon" style="background:rgba(78,205,196,0.12);border:1px solid rgba(78,205,196,0.25);">
                <span style="color:#4ECDC4;">🚌</span>
            </div>
            <div class="expense-info">
                <div class="expense-amount">990 ₺</div>
                <div class="expense-meta">Ulaşım · 2.9 saat</div>
            </div>
            <div class="expense-right">
                <div class="expense-date">8 Şub 2026</div>
                <div class="expense-check">✓</div>
            </div>
        </div>

        <div class="expense-item">
            <div class="expense-icon" style="background:rgba(255,107,107,0.12);border:1px solid rgba(255,107,107,0.25);">
                <span style="color:#FF6B6B;">🍕</span>
            </div>
            <div class="expense-info">
                <div class="expense-amount">550 ₺</div>
                <div class="expense-meta">Yeme-İçme · 1.6 saat</div>
            </div>
            <div class="expense-right">
                <div class="expense-date">8 Şub 2026</div>
                <div class="expense-check">✓</div>
            </div>
        </div>
    </div>
    {TAB_BAR}
    """
    body = f"""
    <div class="headline-section">
        <h1 class="headline">Her harcamayı<br>saatinle gör</h1>
    </div>
    <div class="phone-container">
        <div class="phone-frame">
            <div class="notch"></div>
            <div class="screen">{screen}</div>
            <div class="home-bar"></div>
        </div>
    </div>
    """
    return html_page(body, css)


# ═══════════════════════════════════════════════════════════════════════════
# FRAME 3 — DECISIONS
# ═══════════════════════════════════════════════════════════════════════════

def frame_3_decisions() -> str:
    css = """
    .decision-content {
        padding: 88px 28px 60px;
        display: flex;
        flex-direction: column;
        height: 100%;
    }
    .sheet-handle {
        width: 50px; height: 5px;
        border-radius: 3px;
        background: rgba(255,255,255,0.15);
        margin: 0 auto 24px;
    }
    .sheet-title {
        font-size: 30px;
        font-weight: 700;
        color: #F5F5F7;
        text-align: center;
        margin-bottom: 36px;
    }
    /* Result card */
    .result-card {
        background: linear-gradient(145deg, rgba(95,74,139,0.3), rgba(40,30,65,0.2));
        border: 1px solid rgba(95,74,139,0.3);
        border-radius: 28px;
        padding: 36px;
        text-align: center;
        margin-bottom: 32px;
    }
    .result-amount {
        font-size: 72px;
        font-weight: 800;
        color: #F5F5F7;
        letter-spacing: -1px;
    }
    .result-category {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(78,205,196,0.1);
        border: 1px solid rgba(78,205,196,0.2);
        border-radius: 12px;
        padding: 8px 18px;
        font-size: 22px;
        color: #4ECDC4;
        margin: 16px 0 28px;
    }
    .result-divider {
        width: 60px; height: 3px;
        background: rgba(95,74,139,0.4);
        border-radius: 2px;
        margin: 0 auto 28px;
    }
    .result-hours-label {
        font-size: 22px;
        color: #8B8B9E;
        margin-bottom: 8px;
        letter-spacing: 2px;
        font-weight: 600;
    }
    .result-hours {
        font-size: 80px;
        font-weight: 800;
        color: #FEFACD;
        line-height: 1;
    }
    .result-hours-unit {
        font-size: 30px;
        font-weight: 600;
        color: rgba(254,250,205,0.6);
        margin-top: 4px;
    }
    .result-ring {
        width: 160px; height: 160px;
        border-radius: 50%;
        border: 6px solid rgba(95,74,139,0.2);
        margin: 10px auto 20px;
        position: relative;
        display: flex; align-items: center; justify-content: center;
        flex-direction: column;
    }
    .result-ring::after {
        content: '';
        position: absolute;
        top: -6px; left: -6px; right: -6px; bottom: -6px;
        border-radius: 50%;
        border: 6px solid transparent;
        border-top-color: #FEFACD;
        border-right-color: #FEFACD;
        border-bottom-color: #FEFACD;
        transform: rotate(-30deg);
    }
    .result-insight {
        font-size: 22px;
        color: #8B8B9E;
        margin-top: 20px;
        font-style: italic;
        line-height: 1.4;
        padding: 0 10px;
    }
    /* Decision buttons */
    .decision-label {
        font-size: 26px;
        color: #8B8B9E;
        text-align: center;
        margin-bottom: 20px;
        font-weight: 500;
    }
    .decision-row {
        display: flex;
        gap: 14px;
    }
    .decision-btn {
        flex: 1;
        border-radius: 22px;
        padding: 28px 12px;
        text-align: center;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 12px;
    }
    .decision-btn .d-icon {
        width: 56px; height: 56px;
        border-radius: 16px;
        display: flex; align-items: center; justify-content: center;
        font-size: 26px;
    }
    .decision-btn .d-label {
        font-size: 24px;
        font-weight: 600;
    }
    .btn-yes {
        background: rgba(248,113,113,0.08);
        border: 1px solid rgba(248,113,113,0.2);
    }
    .btn-yes .d-icon {
        background: rgba(248,113,113,0.15);
        border: 1px solid rgba(248,113,113,0.3);
        color: #F87171;
    }
    .btn-yes .d-label { color: #F87171; }
    .btn-think {
        background: rgba(251,191,36,0.08);
        border: 1px solid rgba(251,191,36,0.2);
    }
    .btn-think .d-icon {
        background: rgba(251,191,36,0.15);
        border: 1px solid rgba(251,191,36,0.3);
        color: #FBBF24;
    }
    .btn-think .d-label { color: #FBBF24; }
    .btn-no {
        background: rgba(34,211,238,0.1);
        border: 1.5px solid rgba(34,211,238,0.35);
        box-shadow: 0 0 30px rgba(34,211,238,0.08);
    }
    .btn-no .d-icon {
        background: rgba(34,211,238,0.2);
        border: 1px solid rgba(34,211,238,0.4);
        color: #22D3EE;
    }
    .btn-no .d-label { color: #22D3EE; }
    """
    screen = f"""
    {STATUS_BAR}
    <div class="decision-content">
        <div class="sheet-handle"></div>
        <div class="sheet-title">Harcama Ekle</div>

        <div class="result-card">
            <div class="result-amount">990 ₺</div>
            <div class="result-category">🚌 Ulaşım</div>
            <div class="result-divider"></div>
            <div class="result-hours-label">⏰ ÇALIŞMA KARŞILIĞI</div>
            <div class="result-ring">
                <div class="result-hours">2.9</div>
                <div class="result-hours-unit">SAAT</div>
            </div>
            <div class="result-insight">"Bu harcama maaşının %2.9'una denk"</div>
        </div>

        <div class="decision-label">Kararını ver:</div>
        <div class="decision-row">
            <div class="decision-btn btn-yes">
                <div class="d-icon">✓</div>
                <div class="d-label">Aldım</div>
            </div>
            <div class="decision-btn btn-think">
                <div class="d-icon">⏳</div>
                <div class="d-label">Düşünüyorum</div>
            </div>
            <div class="decision-btn btn-no">
                <div class="d-icon">✕</div>
                <div class="d-label">Vazgeçtim</div>
            </div>
        </div>
    </div>
    """
    body = f"""
    <div class="headline-section">
        <h1 class="headline">Aldım. Düşünüyorum.<br>Vazgeçtim.</h1>
        <p class="subtitle">Her harcamada bilinçli karar</p>
    </div>
    <div class="phone-container">
        <div class="phone-frame">
            <div class="notch"></div>
            <div class="screen">{screen}</div>
            <div class="home-bar"></div>
        </div>
    </div>
    """
    return html_page(body, css)


# ═══════════════════════════════════════════════════════════════════════════
# FRAME 4 — REPORTS
# ═══════════════════════════════════════════════════════════════════════════

def frame_4_reports() -> str:
    css = """
    .report-content { padding: 88px 24px 120px; }
    .report-header {
        font-size: 42px;
        font-weight: 800;
        color: #F5F5F7;
        margin-bottom: 20px;
    }
    .filter-row {
        display: flex; gap: 10px;
        margin-bottom: 28px;
    }
    .filter-chip {
        padding: 10px 22px;
        border-radius: 14px;
        font-size: 22px;
        font-weight: 600;
        background: rgba(255,255,255,0.04);
        border: 1px solid rgba(255,255,255,0.06);
        color: #6B6B7E;
    }
    .filter-chip.active {
        background: rgba(95,74,139,0.2);
        border-color: rgba(95,74,139,0.4);
        color: #FEFACD;
    }
    /* Stats grid */
    .stats-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 14px;
        margin-bottom: 28px;
    }
    .stat-card {
        background: rgba(19,19,26,0.6);
        border: 1px solid rgba(255,255,255,0.04);
        border-radius: 22px;
        padding: 22px;
    }
    .stat-icon-row {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 14px;
    }
    .stat-icon {
        width: 40px; height: 40px;
        border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        font-size: 20px;
    }
    .stat-title {
        font-size: 20px;
        color: #8B8B9E;
        font-weight: 500;
    }
    .stat-value {
        font-size: 38px;
        font-weight: 800;
        color: #F5F5F7;
        margin-bottom: 4px;
    }
    .stat-sub {
        font-size: 19px;
        color: #6B6B7E;
    }
    /* Pie chart */
    .chart-section {
        background: rgba(19,19,26,0.6);
        border: 1px solid rgba(255,255,255,0.04);
        border-radius: 22px;
        padding: 24px;
        margin-bottom: 20px;
    }
    .chart-title {
        font-size: 24px;
        font-weight: 700;
        color: #F5F5F7;
        margin-bottom: 20px;
    }
    .pie-wrapper {
        display: flex;
        align-items: center;
        gap: 30px;
    }
    .pie-chart {
        width: 180px; height: 180px;
        border-radius: 50%;
        background: conic-gradient(
            #FF6B6B 0deg 120deg,
            #4ECDC4 120deg 210deg,
            #9B59B6 210deg 275deg,
            #3498DB 275deg 320deg,
            #6B6B7E 320deg 360deg
        );
        position: relative;
        flex-shrink: 0;
    }
    .pie-hole {
        position: absolute;
        top: 35px; left: 35px; right: 35px; bottom: 35px;
        border-radius: 50%;
        background: rgba(19,19,26,0.95);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
    }
    .pie-total { font-size: 28px; font-weight: 800; color: #F5F5F7; }
    .pie-total-label { font-size: 16px; color: #6B6B7E; }
    .pie-legend { flex: 1; }
    .legend-item {
        display: flex; align-items: center; gap: 10px;
        margin-bottom: 12px;
        font-size: 20px;
        color: #8B8B9E;
    }
    .legend-dot {
        width: 14px; height: 14px;
        border-radius: 4px;
        flex-shrink: 0;
    }
    .legend-value {
        margin-left: auto;
        font-weight: 600;
        color: #F5F5F7;
    }
    """
    screen = f"""
    {STATUS_BAR}
    <div class="report-content">
        <div class="report-header">Analiz</div>
        <div class="filter-row">
            <div class="filter-chip">Bu Hafta</div>
            <div class="filter-chip active">Bu Ay</div>
            <div class="filter-chip">Tümü</div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon-row">
                    <div class="stat-icon" style="background:rgba(248,113,113,0.12);"><span style="color:#F87171;">🛒</span></div>
                    <div class="stat-title">Toplam Harcama</div>
                </div>
                <div class="stat-value">5.240 ₺</div>
                <div class="stat-sub">15.3 saat karşılığı</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon-row">
                    <div class="stat-icon" style="background:rgba(34,211,238,0.12);"><span style="color:#22D3EE;">🛡️</span></div>
                    <div class="stat-title">Toplam Tasarruf</div>
                </div>
                <div class="stat-value" style="color:#22D3EE;">2.100 ₺</div>
                <div class="stat-sub">6.1 saat kurtarıldı</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon-row">
                    <div class="stat-icon" style="background:rgba(59,130,246,0.12);"><span style="color:#3B82F6;">📋</span></div>
                    <div class="stat-title">Harcama Sayısı</div>
                </div>
                <div class="stat-value">24</div>
                <div class="stat-sub">12 aldım · 12 vazgeçtim</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon-row">
                    <div class="stat-icon" style="background:rgba(74,222,128,0.12);"><span style="color:#4ADE80;">📈</span></div>
                    <div class="stat-title">Vazgeçme Oranı</div>
                </div>
                <div class="stat-value" style="color:#4ADE80;">%38</div>
                <div class="stat-sub">Daha iyi olabilir</div>
            </div>
        </div>

        <div class="chart-section">
            <div class="chart-title">Kategori Dağılımı</div>
            <div class="pie-wrapper">
                <div class="pie-chart">
                    <div class="pie-hole">
                        <div class="pie-total">5.2K</div>
                        <div class="pie-total-label">Toplam</div>
                    </div>
                </div>
                <div class="pie-legend">
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#FF6B6B;"></div>
                        Yeme-İçme
                        <span class="legend-value">2.100 ₺</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#4ECDC4;"></div>
                        Ulaşım
                        <span class="legend-value">1.500 ₺</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#9B59B6;"></div>
                        Giyim
                        <span class="legend-value">890 ₺</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#3498DB;"></div>
                        Eğlence
                        <span class="legend-value">450 ₺</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#6B6B7E;"></div>
                        Diğer
                        <span class="legend-value">300 ₺</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    {TAB_BAR}
    """
    body = f"""
    <div class="headline-section">
        <h1 class="headline">Paran nereye gidiyor?</h1>
        <p class="subtitle">Detaylı analiz ve raporlar</p>
    </div>
    <div class="phone-container">
        <div class="phone-frame">
            <div class="notch"></div>
            <div class="screen">{screen}</div>
            <div class="home-bar"></div>
        </div>
    </div>
    """
    return html_page(body, css)


# ═══════════════════════════════════════════════════════════════════════════
# FRAME 5 — BADGES
# ═══════════════════════════════════════════════════════════════════════════

def frame_5_badges() -> str:
    css = """
    .badge-content { padding: 88px 24px 120px; }
    .badge-header {
        font-size: 42px;
        font-weight: 800;
        color: #F5F5F7;
        margin-bottom: 6px;
    }
    .badge-count {
        font-size: 24px;
        color: #8B8B9E;
        margin-bottom: 28px;
    }
    .badge-count span {
        color: #FEFACD;
        font-weight: 700;
    }
    .badge-grid {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 14px;
    }
    .badge-card {
        background: rgba(19,19,26,0.6);
        border: 1px solid rgba(255,255,255,0.04);
        border-radius: 20px;
        padding: 22px 14px;
        text-align: center;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
    }
    .badge-card.earned {
        border-color: rgba(95,74,139,0.4);
        background: rgba(95,74,139,0.1);
        box-shadow: 0 0 25px rgba(95,74,139,0.1);
    }
    .badge-card.locked {
        opacity: 0.4;
        border-style: dashed;
    }
    .badge-emoji {
        font-size: 48px;
        filter: drop-shadow(0 2px 8px rgba(0,0,0,0.3));
    }
    .badge-card.locked .badge-emoji {
        filter: grayscale(0.7) drop-shadow(0 2px 8px rgba(0,0,0,0.3));
    }
    .badge-name {
        font-size: 19px;
        font-weight: 600;
        color: #F5F5F7;
        line-height: 1.2;
    }
    .badge-card.locked .badge-name {
        color: #6B6B7E;
    }
    .badge-level {
        font-size: 16px;
        color: #8B8B9E;
    }
    .badge-card.earned .badge-level {
        color: #FEFACD;
    }
    """
    badges = [
        ("🚀", "İlk Adım", "Kazanıldı", True),
        ("🔥", "3 Gün Seri", "Kazanıldı", True),
        ("💰", "1K Tasarruf", "Kazanıldı", True),
        ("🎯", "Hedef Koyucu", "Kazanıldı", True),
        ("📊", "Analist", "Kazanıldı", True),
        ("🛡️", "Koruyucu", "Kazanıldı", True),
        ("⚡", "Hızlı Karar", "Kazanıldı", True),
        ("🌟", "Parlayan Yıldız", "Kazanıldı", True),
        ("🎖️", "Disiplinli", "Kazanıldı", True),
        ("👑", "Kral", "Kilitli", False),
        ("💎", "Elmas", "Kilitli", False),
        ("🏅", "Altın Çağ", "Kilitli", False),
    ]
    badge_html = ""
    for emoji, name, level, earned in badges:
        cls = "earned" if earned else "locked"
        badge_html += f"""
        <div class="badge-card {cls}">
            <div class="badge-emoji">{emoji}</div>
            <div class="badge-name">{name}</div>
            <div class="badge-level">{level}</div>
        </div>
        """

    screen = f"""
    {STATUS_BAR}
    <div class="badge-content">
        <div class="badge-header">Rozetler</div>
        <div class="badge-count"><span>12</span> / 57 kazanıldı</div>
        <div class="badge-grid">
            {badge_html}
        </div>
    </div>
    {TAB_BAR}
    """
    body = f"""
    <div class="headline-section">
        <h1 class="headline">57 rozet.<br>Gerçek ödüller.</h1>
        <p class="subtitle">Finansal disiplini oyunlaştır</p>
    </div>
    <div class="phone-container">
        <div class="phone-frame">
            <div class="notch"></div>
            <div class="screen">{screen}</div>
            <div class="home-bar"></div>
        </div>
    </div>
    """
    return html_page(body, css)


# ═══════════════════════════════════════════════════════════════════════════
# FRAME 6 — AI CHAT
# ═══════════════════════════════════════════════════════════════════════════

def frame_6_ai_chat() -> str:
    css = """
    .chat-content {
        padding: 88px 24px 30px;
        display: flex;
        flex-direction: column;
        height: 100%;
    }
    .chat-header {
        text-align: center;
        margin-bottom: 28px;
    }
    .chat-header-title {
        font-size: 34px;
        font-weight: 700;
        color: #F5F5F7;
    }
    .chat-header-sub {
        font-size: 20px;
        color: #8B8B9E;
        margin-top: 4px;
    }
    .chat-ai-avatar {
        width: 70px; height: 70px;
        border-radius: 50%;
        background: linear-gradient(135deg, #5F4A8B, #7B62A8);
        display: flex; align-items: center; justify-content: center;
        font-size: 34px;
        margin: 0 auto 20px;
        box-shadow: 0 4px 20px rgba(95,74,139,0.4);
    }
    .chat-messages {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 18px;
        overflow: hidden;
    }
    .msg {
        max-width: 85%;
        border-radius: 22px;
        padding: 20px 24px;
        font-size: 24px;
        line-height: 1.45;
    }
    .msg-user {
        align-self: flex-end;
        background: linear-gradient(135deg, #5F4A8B, #4A3870);
        color: #F5F5F7;
        border-bottom-right-radius: 6px;
    }
    .msg-ai {
        align-self: flex-start;
        background: rgba(19,19,26,0.8);
        border: 1px solid rgba(255,255,255,0.06);
        color: #F5F5F7;
        border-bottom-left-radius: 6px;
    }
    .msg-ai .highlight {
        color: #FEFACD;
        font-weight: 600;
    }
    .msg-ai .stat-line {
        display: block;
        padding: 3px 0;
    }
    .chat-input-bar {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 16px 20px;
        background: rgba(19,19,26,0.6);
        border: 1px solid rgba(255,255,255,0.06);
        border-radius: 20px;
        margin-top: 18px;
        margin-bottom: 48px;
    }
    .chat-input-text {
        flex: 1;
        font-size: 22px;
        color: #6B6B7E;
    }
    .chat-input-mic {
        width: 44px; height: 44px;
        border-radius: 50%;
        background: linear-gradient(135deg, #5F4A8B, #7B62A8);
        display: flex; align-items: center; justify-content: center;
        font-size: 22px;
    }
    """
    screen = f"""
    {STATUS_BAR}
    <div class="chat-content">
        <div class="chat-header">
            <div class="chat-ai-avatar">✨</div>
            <div class="chat-header-title">AI Asistan</div>
            <div class="chat-header-sub">Vantag Finansal Asistan</div>
        </div>

        <div class="chat-messages">
            <div class="msg msg-user">Bu ay ne kadar harcadım?</div>

            <div class="msg msg-ai">
                Şubat ayında toplam <span class="highlight">5.240₺</span> harcadınız.
                <br><br>
                📊 En yüksek kategoriler:
                <span class="stat-line">1. Yeme-İçme: <span class="highlight">2.100₺</span></span>
                <span class="stat-line">2. Ulaşım: <span class="highlight">1.500₺</span></span>
                <span class="stat-line">3. Faturalar: <span class="highlight">890₺</span></span>
                <br>
                Geçen aya göre <span class="highlight">%12 azalma</span> var! 🎉
            </div>

            <div class="msg msg-user">Tasarruf için ne önerirsin?</div>

            <div class="msg msg-ai">
                Yeme-İçme kategorisinde haftada 3 kez dışarıda yemek yerine
                evde hazırlayarak ayda yaklaşık
                <span class="highlight">800₺ tasarruf</span> edebilirsiniz! 💡
                <br><br>
                Bu, <span class="highlight">2.3 saat</span> daha az çalışmak demek ⏰
            </div>
        </div>

        <div class="chat-input-bar">
            <div class="chat-input-text">Harcamalarını sor...</div>
            <div class="chat-input-mic">🎤</div>
        </div>
    </div>
    """
    body = f"""
    <div class="headline-section">
        <h1 class="headline">Yapay zekaya<br>harcamalarını sor</h1>
        <p class="subtitle">Kişisel finans asistanın</p>
    </div>
    <div class="phone-container">
        <div class="phone-frame">
            <div class="notch"></div>
            <div class="screen">{screen}</div>
            <div class="home-bar"></div>
        </div>
    </div>
    """
    return html_page(body, css)


# ═══════════════════════════════════════════════════════════════════════════
# RENDERING
# ═══════════════════════════════════════════════════════════════════════════

FRAMES = [
    ("appstore_1_hook",      frame_1_hook),
    ("appstore_2_home",      frame_2_home),
    ("appstore_3_decisions", frame_3_decisions),
    ("appstore_4_reports",   frame_4_reports),
    ("appstore_5_badges",    frame_5_badges),
    ("appstore_6_ai_chat",   frame_6_ai_chat),
]


async def render_all():
    try:
        from playwright.async_api import async_playwright
    except ImportError:
        print("ERROR: playwright not installed.")
        print("  pip install playwright --break-system-packages")
        print("  python -m playwright install chromium")
        sys.exit(1)

    os.makedirs(FRAMES_DIR, exist_ok=True)

    print(f"Vantag App Store Screenshot Generator (Playwright)")
    print(f"{'=' * 52}")
    print(f"  Output size : {W} × {H} px")
    print(f"  HTML frames : {FRAMES_DIR}/")
    print(f"  PNG output  : {OUT_DIR}/")
    print()

    async with async_playwright() as p:
        browser = await p.chromium.launch()

        for i, (name, gen_fn) in enumerate(FRAMES, 1):
            print(f"  [{i}/6] {name}")

            # Generate HTML
            html = gen_fn()
            html_path = os.path.join(FRAMES_DIR, f"{name}.html")
            with open(html_path, "w", encoding="utf-8") as f:
                f.write(html)
            print(f"        HTML → {os.path.basename(html_path)}")

            # Render to PNG
            page = await browser.new_page(
                viewport={"width": W, "height": H},
                device_scale_factor=1,
            )
            await page.set_content(html, wait_until="domcontentloaded")
            # Small delay to let system fonts settle
            await page.wait_for_timeout(300)

            png_path = os.path.join(OUT_DIR, f"{name}.png")
            await page.screenshot(path=png_path, type="png")
            await page.close()

            size_kb = os.path.getsize(png_path) / 1024
            print(f"        PNG  → {os.path.basename(png_path)}  ({size_kb:.0f} KB)")

        await browser.close()

    print()
    print(f"Done! 6 screenshots saved to {OUT_DIR}/")
    print(f"HTML sources saved to {FRAMES_DIR}/")


def main():
    asyncio.run(render_all())


if __name__ == "__main__":
    main()
