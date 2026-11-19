#!/usr/bin/env python3
"""Synthesize the promo-demo's original audio bed (no external assets).
120 BPM kick + hats, snare on 2/4, a riser into the f150 scene change,
impacts at f150 (5.0s) and f330 (11.0s). Output: assets/mixed_audio.wav
(44.1kHz stereo). Original synthesis - licence-free by construction.
"""
import json, wave
import numpy as np

SR, FPS, TOTAL_F = 44100, 30, 390
T = TOTAL_F / FPS
t = np.arange(int(SR * T)) / SR
mix = np.zeros_like(t)


def _put(i, sig):
    n = min(len(sig), len(mix) - i)
    if n > 0:
        mix[i:i + n] += sig[:n]

def kick(t0):
    i = int(t0 * SR); n = int(0.18 * SR)
    e = np.exp(-np.linspace(0, 8, n))
    f = 55 + 40 * np.exp(-np.linspace(0, 20, n))
    _put(i, 0.9 * np.sin(2 * np.pi * f * np.arange(n) / SR) * e)

def snare(t0):
    i = int(t0 * SR); n = int(0.12 * SR)
    rng = np.random.default_rng(7)
    _put(i, 0.35 * rng.standard_normal(n) * np.exp(-np.linspace(0, 12, n)))

def hat(t0):
    i = int(t0 * SR); n = int(0.04 * SR)
    rng = np.random.default_rng(3)
    _put(i, 0.12 * rng.standard_normal(n) * np.exp(-np.linspace(0, 30, n)))

def impact(t0):
    i = int(t0 * SR); n = int(0.5 * SR)
    e = np.exp(-np.linspace(0, 6, n))
    f = 90 * np.exp(-np.linspace(0, 4, n)) + 30
    rng = np.random.default_rng(11)
    _put(i, (0.8 * np.sin(2 * np.pi * f * np.arange(n) / SR)
             + 0.3 * rng.standard_normal(n)) * e)

def riser(t0, t1):
    i0, i1 = int(t0 * SR), int(t1 * SR); n = i1 - i0
    f = np.linspace(200, 1600, n)
    ph = np.cumsum(2 * np.pi * f / SR)
    _put(i0, 0.18 * np.sin(ph) * np.linspace(0, 1, n) ** 2)

beat = 60.0 / 120.0  # 0.5s
b = 0.0
while b < T:
    kick(b); hat(b + beat / 2); b += beat
bar = 0.0
while bar < T:
    snare(bar + beat); snare(bar + 3 * beat); bar += 4 * beat
riser(4.0, 5.0)
impact(5.0)    # scene change flash (frame 150)
impact(11.0)   # end card hit (frame 330)

mix = np.clip(mix, -1, 1)
st = np.stack([mix, mix], axis=1)
pcm = (st * 32767).astype(np.int16)
import os
os.makedirs("assets", exist_ok=True)
with wave.open("assets/mixed_audio.wav", "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print("wrote assets/mixed_audio.wav", round(T, 2), "s")
print("event targets: flash f150=5.000s, endcard f330=11.000s, kicks every 0.5s")
