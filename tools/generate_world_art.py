#!/usr/bin/env python3
"""Original procedural 320×180 pixel scene plates: 7 individual visual identities."""
from PIL import Image, ImageDraw
from pathlib import Path
import random,math
ROOT=Path(__file__).resolve().parents[1]/'varliklar/sprites'
PALETTES={
2:('#182b33','#304552','#ae7151','#ead8b5','#68767b'),
3:('#24382e','#526449','#bd7a57','#e4d9b9','#78a8a1'),
4:('#1d2937','#394f60','#b38a54','#ded8b9','#687e8b'),
5:('#223f49','#3e7070','#c8a46b','#e1d5b4','#75928b'),
6:('#372b42','#684858','#c39a65','#e7dcbf','#897a8c'),
7:('#1d3440','#41626b','#cb8b57','#e0d7c4','#73968c')}

def make(w):
    a,b,c,d,e=PALETTES[w];img=Image.new('RGB',(320,180),a);p=ImageDraw.Draw(img)
    rnd=random.Random(1000+w)
    for y in range(180):
        if y>87:p.line((0,y,320,y),fill=b if (y//10)%2 else a)
    # Discreet stars/grain; no glitter gradients.
    for i in range(65):
        x=rnd.randrange(320);y=rnd.randrange(12,88)
        if rnd.randrange(4)==0:p.point((x,y),fill=e)
    if w==2: # precisely meshed clocks and stepped buildings
        for x,h in [(0,88),(36,106),(85,84),(132,113),(188,93),(241,104),(279,77)]:
            p.rectangle((x,178-h,x+52,165),fill=b,outline=a,width=2)
            p.rectangle((x+7,178-h+11,x+20,178-h+30),fill=a)
            p.rectangle((x+26,178-h+11,x+42,178-h+30),fill=a)
        for x,y,r in [(71,82,20),(168,53,25),(270,86,18)]:
            p.ellipse((x-r,y-r,x+r,y+r),fill=a,outline=c,width=4)
            for angle in (0,90,180,270):
                xx=x+int(math.cos(math.radians(angle))*r);yy=y+int(math.sin(math.radians(angle))*r)
                p.line((x,y,xx,yy),fill=d,width=2)
            p.ellipse((x-3,y-3,x+3,y+3),fill=c)
        p.rectangle((0,155,320,180),fill=a)
    elif w==3: # greenhouse lattices and broad soil terraces
        p.rectangle((0,122,320,180),fill=b)
        for x,r in [(72,66),(214,77)]:
            p.pieslice((x-r,40,x+r,175),180,360,fill=e,outline=d,width=3)
            for dx in (-38,0,38):p.line((x+dx,115,x+dx,55 if dx==0 else 70),fill=a,width=2)
            p.line((x-r,112,x+r,112),fill=d,width=3)
        p.rectangle((12,138,309,152),fill=c,outline=a,width=3)
        for x in range(23,312,31):
            h=rnd.randrange(8,27)
            p.line((x,136,x,136-h),fill=d,width=2)
            p.ellipse((x-8,135-h,x,141-h),fill=b)
            p.ellipse((x,135-h,x+8,141-h),fill=e)
        p.line((0,166,320,166),fill=c,width=3)
    elif w==4: # stacked archival towers
        p.rectangle((0,110,320,180),fill=b)
        for x in (10,91,172,253):
            p.rectangle((x,28,x+61,157),fill=a,outline=c,width=3)
            for y in (50,83,116,147):
                p.line((x+5,y,x+56,y),fill=c,width=2)
                for i in range(4):
                    xx=x+9+i*11
                    p.rectangle((xx,y-19,xx+8,y-2),fill=[b,e,c,d][(i+y//30)%4])
            p.rectangle((x+4,158,x+57,165),fill=c)
        p.polygon([(142,0),(177,0),(177,19),(142,19)],fill=c)
        p.rectangle((154,19,165,42),fill=d)
    elif w==5: # slate valley and asymmetrical bridge
        p.polygon([(0,112),(35,75),(91,109),(143,66),(218,121),(288,58),(320,101),(320,180),(0,180)],fill=b)
        p.polygon([(0,155),(44,133),(120,149),(182,122),(257,152),(320,129),(320,180),(0,180)],fill=e)
        p.rectangle((0,146,320,163),fill=a)
        p.line((7,125,310,125),fill=c,width=6)
        for x in (35,78,126,173,222,267):
            p.line((x,125,x,158),fill=d,width=3)
            p.line((x,125,x+18,109),fill=c,width=2)
        p.line((0,161,320,161),fill=d,width=2)
    elif w==6: # loom/print workshop
        p.rectangle((0,98,320,180),fill=b)
        p.rectangle((36,21,271,161),fill=a,outline=c,width=5)
        p.rectangle((50,36,254,147),fill=b)
        for x in range(56,249,12):
            p.line((x,39,x,143),fill=d if (x//12)%2 else e,width=3)
        for y in range(42,143,14):
            p.line((53,y,249,y),fill=c,width=4)
        for x,y in ((37,157),(270,157)):
            p.ellipse((x-9,y-9,x+9,y+9),fill=c,outline=d,width=3)
        p.polygon([(23,12),(55,12),(40,24)],fill=c)
    elif w==7: # lively civic station, non-combat city
        for x,h,width in [(0,72,35),(39,117,54),(99,82,46),(154,134,52),(211,93,44),(265,112,54)]:
            p.rectangle((x,160-h,x+width,160),fill=b,outline=e,width=2)
            for dx in range(x+9,x+width-3,12):
                for dy in range(169-h,155,17):p.rectangle((dx,dy,dx+5,dy+7),fill=c)
        p.rectangle((0,158,320,180),fill=a)
        p.line((0,168,320,168),fill=d,width=3)
        p.rectangle((72,146,202,167),fill=c,outline=a,width=2)
        for x in (83,113,143,173):p.rectangle((x,151,x+18,161),fill=d)
    # one subtle identifying marker in lower right
    p.rectangle((292,162,308,175),fill=c,outline=a,width=2)
    img.save(ROOT/f'world_{w}.png',optimize=True)
    return img
if __name__=='__main__':
    for world in range(2,8):make(world)
    print('generated world plates 2-7')

def make_characters():
    # Original little pixel figures, drawn as 28x36 sprites with clear silhouettes.
    sets={1:('#d3ac74','#305c68','#9b563d'),2:('#d8b38a','#6b535e','#ad7750'),3:('#c8a27b','#537354','#a77750'),4:('#d5ac8d','#4c5a72','#d6b07b'),5:('#e0ad8a','#446b65','#bd8054'),6:('#d3a58d','#715571','#c8a06e'),7:('#b2bd8d','#3b7174','#bd865c')}
    for w,(face,coat,detail) in sets.items():
        im=Image.new('RGBA',(32,40),(0,0,0,0)); dr=ImageDraw.Draw(im)
        if w==7: # seed-shaped mobile sensor companion, not humanized robot
            dr.ellipse((8,13,25,32),fill=coat,outline=detail,width=2)
            dr.polygon([(16,14),(22,7),(26,10),(20,16)],fill=face)
            dr.rectangle((12,23,14,25),fill=face)
            dr.rectangle((20,23,22,25),fill=face)
            dr.rectangle((11,33,23,36),fill=detail)
        else:
            dr.rectangle((9,25,24,37),fill=coat)
            dr.rectangle((7,28,9,34),fill=face)
            dr.rectangle((24,28,26,34),fill=face)
            dr.rectangle((10,37,15,39),fill=detail)
            dr.rectangle((19,37,24,39),fill=detail)
            dr.ellipse((10,9,24,25),fill=face)
            dr.rectangle((12,17,14,19),fill='#26303a')
            dr.rectangle((20,17,22,19),fill='#26303a')
            dr.line((15,21,19,21),fill='#8b5548',width=1)
            if w==1:dr.polygon([(6,13),(9,6),(25,6),(28,13)],fill=detail);dr.rectangle((5,12,28,14),fill=coat)
            elif w==2:dr.rectangle((9,6,25,12),fill=detail);dr.rectangle((6,11,28,13),fill=coat)
            elif w==3:dr.ellipse((9,6,25,12),fill=detail);dr.line((9,8,5,6),fill=coat,width=2)
            elif w==4:dr.rectangle((9,5,24,11),fill=detail)
            elif w==5:dr.polygon([(8,13),(16,4),(25,13)],fill=detail)
            elif w==6:dr.line((11,7,22,7),fill=detail,width=5)
        im.save(ROOT/f'character_{w}.png',optimize=True)

if __name__=='__main__':
    make_characters()
    print('generated 7 original character sprites')
