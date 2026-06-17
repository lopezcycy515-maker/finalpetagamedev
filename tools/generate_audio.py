"""Generate pastel SFX and looping BGM WAV files for Lopezcy Run."""
import math
import os
import struct
import wave

SAMPLE_RATE = 44100
AUDIO_ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")


def _env(t: float, duration: float, attack: float = 0.01, release: float = 0.05) -> float:
    if t < attack:
        return t / max(attack, 1e-6)
    if t > duration - release:
        return max((duration - t) / max(release, 1e-6), 0.0)
    return 1.0


def _sine(freq: float, t: float) -> float:
    return math.sin(2.0 * math.pi * freq * t)


def _write_wav(path: str, samples: list[int]) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    peak = max((abs(s) for s in samples), default=1)
    scale = 30000 / peak if peak > 0 else 1.0
    with wave.open(path, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = b"".join(struct.pack("<h", int(max(-32767, min(32767, s * scale)))) for s in samples)
        wf.writeframes(frames)
    print(f"Saved {path}")


def _render(duration: float, fn) -> list[int]:
    count = int(SAMPLE_RATE * duration)
    out = []
    for i in range(count):
        t = i / SAMPLE_RATE
        out.append(int(fn(t) * 32767))
    return out


def make_jump() -> None:
    def fn(t):
        freq = 320 + t * 900
        return _sine(freq, t) * _env(t, 0.14, 0.005, 0.04) * 0.35
    _write_wav(os.path.join(AUDIO_ROOT, "jump.wav"), _render(0.14, fn))


def make_hurt() -> None:
    def fn(t):
        freq = 420 - t * 700
        return (_sine(freq, t) + _sine(freq * 1.5, t) * 0.3) * _env(t, 0.22, 0.005, 0.08) * 0.4
    _write_wav(os.path.join(AUDIO_ROOT, "hurt.wav"), _render(0.22, fn))


def make_sprint() -> None:
    def fn(t):
        shimmer = _sine(1200 + t * 2000, t) * 0.2
        base = _sine(520, t) * 0.25
        return (base + shimmer) * _env(t, 0.28, 0.01, 0.1) * 0.45
    _write_wav(os.path.join(AUDIO_ROOT, "sprint.wav"), _render(0.28, fn))


def make_hop() -> None:
    notes = [659.25, 783.99, 987.77]
    step = 0.07
    samples = []

    def fn(t):
        idx = min(int(t / step), len(notes) - 1)
        local = t - idx * step
        freq = notes[idx]
        return _sine(freq, local) * _env(local, step, 0.003, 0.03) * 0.38

    _write_wav(os.path.join(AUDIO_ROOT, "hop.wav"), _render(step * len(notes), fn))


def make_shield() -> None:
    def fn(t):
        pop = _sine(180 + t * 80, t) * 0.5
        ring = _sine(640, t) * 0.15 * _env(t, 0.35, 0.02, 0.2)
        return (pop + ring) * _env(t, 0.35, 0.005, 0.12) * 0.42
    _write_wav(os.path.join(AUDIO_ROOT, "shield.wav"), _render(0.35, fn))


def make_shield_break() -> None:
    def fn(t):
        freq = 500 - t * 900
        return _sine(max(freq, 120), t) * _env(t, 0.18, 0.002, 0.08) * 0.35
    _write_wav(os.path.join(AUDIO_ROOT, "shield_break.wav"), _render(0.18, fn))


def make_pass() -> None:
    def fn(t):
        return _sine(880, t) * _env(t, 0.12, 0.003, 0.05) * 0.28
    _write_wav(os.path.join(AUDIO_ROOT, "pass.wav"), _render(0.12, fn))


def make_ui_click() -> None:
    def fn(t):
        return _sine(660, t) * _env(t, 0.08, 0.003, 0.03) * 0.25
    _write_wav(os.path.join(AUDIO_ROOT, "ui_click.wav"), _render(0.08, fn))


def make_bgm() -> None:
    # Cute pastel loop ~8 seconds, C major pentatonic.
    melody = [
        (523.25, 0.35), (587.33, 0.35), (659.25, 0.35), (783.99, 0.5),
        (659.25, 0.35), (587.33, 0.35), (523.25, 0.5), (587.33, 0.35),
        (659.25, 0.35), (783.99, 0.35), (880.0, 0.5), (783.99, 0.35),
        (659.25, 0.35), (587.33, 0.35), (523.25, 0.7),
    ]
    bass = [
        (130.81, 0.7), (146.83, 0.7), (164.81, 0.7), (196.0, 0.7),
        (164.81, 0.7), (146.83, 0.7), (130.81, 0.7), (146.83, 0.7),
    ]

    duration = 8.0
    count = int(SAMPLE_RATE * duration)
    samples = [0.0] * count

    t_cursor = 0.0
    for freq, length in melody:
        start = int(t_cursor * SAMPLE_RATE)
        seg = int(length * SAMPLE_RATE)
        for i in range(seg):
            t = i / SAMPLE_RATE
            if start + i >= count:
                break
            v = _sine(freq, t) * _env(t, length, 0.02, 0.08) * 0.18
            samples[start + i] += v
        t_cursor += length

    t_cursor = 0.0
    for freq, length in bass:
        start = int(t_cursor * SAMPLE_RATE)
        seg = int(length * SAMPLE_RATE)
        for i in range(seg):
            t = i / SAMPLE_RATE
            if start + i >= count:
                break
            v = _sine(freq, t) * _env(t, length, 0.03, 0.12) * 0.12
            samples[start + i] += v
        t_cursor += length

    # Soft pad shimmer across loop.
    for i in range(count):
        t = i / SAMPLE_RATE
        pad = (_sine(392, t) + _sine(494, t)) * 0.03
        samples[i] += pad

    _write_wav(os.path.join(AUDIO_ROOT, "bgm_loop.wav"), [int(s * 32767) for s in samples])


if __name__ == "__main__":
    make_jump()
    make_hurt()
    make_sprint()
    make_hop()
    make_shield()
    make_shield_break()
    make_pass()
    make_ui_click()
    make_bgm()
    print("All audio generated!")
