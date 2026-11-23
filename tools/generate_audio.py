#!/usr/bin/env python3
"""Original minimal procedural tones; no commercial samples and no network."""
from pathlib import Path
from math import sin,pi,exp
from array import array
import wave,sys
ROOT=Path(__file__).resolve().parents[1]/'varliklar/audio'
ROOT.mkdir(parents=True,exist_ok=True)
SR=16000
# Entirely original small motifs; notes are semitone offsets from C4.
MOTIFS={1:[0,4,7,9,7,4,2,0],2:[0,3,7,10,7,3,5,3],3:[0,2,5,7,9,7,5,2],4:[0,5,3,7,10,7,3,5],5:[0,2,4,7,4,2,9,7],6:[0,7,5,4,2,4,7,9],7:[0,4,7,12,9,7,4,2]}

def write(name,samples):
    with wave.open(str(ROOT/name),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(SR)
        data=array('h',(max(-32768,min(32767,int(x*32767))) for x in samples))
        if sys.byteorder=='big':data.byteswap()
        f.writeframes(data.tobytes())

def tone(freq,t,duration):
    env=min(1,t/.035)*exp(-2.7*t/duration)
    return .17*env*(.8*sin(2*pi*freq*t)+.2*sin(2*pi*freq*2*t))
for world,notes in MOTIFS.items():
    beat=.56
    duration=len(notes)*beat
    vals=[]
    for i in range(int(duration*SR)):
        sec=i/SR;index=min(len(notes)-1,int(sec/beat));phase=sec-index*beat
        freq=261.626*2**(notes[index]/12)
        vals.append(.45*tone(freq,phase,beat))
    # Linear 20ms ramp into/out of 4.48 second loop prevents clipping.
    for i in range(min(320,len(vals))):
        vals[i]*=i/320;vals[-1-i]*=i/320
    write(f'world_{world}.wav',vals)
for name,freq,length in [('tap',450,.08),('discover',620,.28),('scan',310,.24)]:
    vals=[tone(freq,i/SR,length) for i in range(int(length*SR))]
    write(f'{name}.wav',vals)
print('Wrote 7 original loops and 3 original SFX')
