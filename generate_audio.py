import wave
import struct
import math

SAMPLE_RATE = 44100

def generate_tone(filename, freq1, freq2, duration_sec, volume=0.5, envelope='flat'):
    num_samples = int(SAMPLE_RATE * duration_sec)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        
        for i in range(num_samples):
            t = float(i) / SAMPLE_RATE
            
            # Simple oscillators
            sample = math.sin(2.0 * math.pi * freq1 * t)
            if freq2 > 0:
                sample += math.sin(2.0 * math.pi * freq2 * t)
                sample *= 0.5
                
            # Envelope
            env = 1.0
            if envelope == 'decay':
                env = max(0, 1.0 - (t / duration_sec))
            elif envelope == 'impulse':
                env = math.exp(-t * 30)
            elif envelope == 'chime':
                # Chime repeats
                env = math.exp(-(t % 0.5) * 5)
                
            value = int(sample * env * volume * 32767.0)
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

# 1. Click: Short, sharp high-frequency pop (impulse envelope)
generate_tone('assets/audio/click.wav', 800, 0, 0.1, volume=0.3, envelope='impulse')

# 2. Pop/Dialogue: Slightly lower, friendlier pop (impulse envelop with lower freq)
generate_tone('assets/audio/pop.wav', 400, 0, 0.15, volume=0.4, envelope='impulse')

# 3. Alarm: A pleasant repeating chime pattern over 3 seconds
generate_tone('assets/audio/alarm.wav', 659.25, 880.0, 3.0, volume=0.6, envelope='chime')

print("Generated audio files successfully.")
