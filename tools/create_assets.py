"""Original pixel art built from code; Pillow is an authoring-only tool, not a game dependency."""
from PIL import Image, ImageDraw
from pathlib import Path
import random
random.seed(14)
ROOT=Path(__file__).resolve().parents[1]/'varliklar/sprites'
ROOT.mkdir(exist_ok=True,parents=True)
C={'sky':'#25454d','far':'#34636a','cloud':'#598077','paper':'#e3d1a8','sand':'#caa06b','gold':'#d5a35d','sun':'#f7d17e','forest':'#1d3a42','water':'#225761','water2':'#316a6a','black':'#132e36','foam':'#7da0a2','rock':'#58645f','dark_rock':'#334c50','white':'#f5e3bb'}
# Landscaped dusk silhouette in hand-set pixel clusters and restricted palette.
w,h=320,180
im=Image.new('RGB',(w,h),C['sky']);d=ImageDraw.Draw(im)
d.rectangle((0,0,w,69),fill=C['sky']);d.rectangle((0,68,w,102),fill=C['far'])
d.rectangle((0,96,w,h),fill=C['water'])
for x,y,ww in [(16,23,29),(167,17,27),(229,38,49)]:
    d.rectangle((x,y,x+ww,y+4),fill=C['cloud']);d.rectangle((x+8,y-3,x+ww-6,y),fill=C['cloud'])
d.rectangle((247,65,256,72),fill=C['sun'])
# distant island silhouettes
for xs,ys in [([0,0,12,22,42,53,61,61],[94,87,84,85,80,86,90,101]),([202,217,230,248,268,292,320],[98,84,84,79,85,89,97])]:
    d.polygon(list(zip(xs,ys)), fill=C['forest'])
# foreground island with hand stepped shoreline
shore=[(0,119),(17,113),(28,109),(49,110),(66,103),(82,103),(101,111),(120,113),(126,123),(124,142),(106,143),(93,148),(63,148),(40,145),(23,149),(0,143)]
d.polygon(shore,fill=C['rock']); d.line(shore+[shore[0]],fill=C['sand'],width=2)
for x,y in [(5,129),(28,122),(49,137),(103,125),(109,136),(73,140)]:
    d.rectangle((x,y,x+9,y+3),fill=C['dark_rock'])
# Lighthouse masonry body, warm window, mechanical copper railing
x=66;d.rectangle((x,54,x+19,105),fill=C['paper']);d.rectangle((x+2,54,x+3,105),fill=C['sand'])
for y in range(60,103,9):d.line((x+1,y,x+18,y),fill=C['sand'])
d.rectangle((x-2,48,x+21,55),fill=C['black']);d.rectangle((x,42,x+19,49),fill=C['gold'])
d.rectangle((x+3,32,x+16,43),fill=C['black']);d.rectangle((x+5,34,x+14,42),fill=C['sun'])
d.rectangle((x+2,29,x+18,32),fill=C['dark_rock']);d.rectangle((x+8,24,x+12,28),fill=C['dark_rock'])
d.rectangle((x+8,85,x+12,105),fill=C['forest'])
# light line into the sea, not flashy glow
d.polygon([(x+15,36),(158,51),(158,61),(x+15,40)],fill='#8d814f')
# pier and posts
d.rectangle((122,117,212,121),fill=C['sand'])
for px in range(130,210,19): d.rectangle((px,120,px+3,137),fill=C['forest'])
for px in range(134,205,24): d.rectangle((px,115,px+14,118),fill=C['paper'])
# surface bands consistent, subtle, pixel aligned
for y in range(112,179,9):
    for x in range((y*7)%36,320,43):
        if 100<x<216 and y<142: continue
        d.line((x,y,x+9,y),fill=C['water2'],width=1)
# tiny postcards / buoy clusters
for x,y in [(242,132),(282,150),(178,154)]:
    d.rectangle((x,y,x+4,y+3),fill=C['gold']);d.rectangle((x+1,y-3,x+2,y),fill=C['paper'])
im.save(ROOT/'coast_dusk.png',optimize=True)

def icon(name,draw):
    img=Image.new('RGBA',(24,24),(0,0,0,0)); pen=ImageDraw.Draw(img);draw(pen);img.save(ROOT/(name+'.png'),optimize=True)

def base(p):
    p.rectangle((0,0,23,23),fill=C['water2']);
    for x,y in [(2,6),(12,20),(13,3)]:p.line((x,y,x+4,y),fill=C['foam'])

def floor(p):
    p.rectangle((0,0,23,23),fill=C['sand']); p.rectangle((1,1,22,22),fill='#b88e61')
    for x,y in [(3,3),(17,6),(8,17),(19,19)]:p.rectangle((x,y,x+3,y+2),fill=C['sand'])

def rock(p):
    floor(p);p.polygon([(3,19),(3,10),(7,6),(16,4),(21,12),(19,21),(6,22)],fill=C['dark_rock']);p.rectangle((7,7,14,10),fill=C['rock']);p.rectangle((8,11,11,13),fill=C['rock'])

def agent(p):
    floor(p);p.rectangle((9,3,14,6),fill=C['gold']);p.rectangle((7,7,16,12),fill=C['black']);p.rectangle((8,8,15,10),fill=C['paper']);p.rectangle((6,12,17,19),fill=C['forest']);p.rectangle((8,20,10,22),fill=C['black']);p.rectangle((13,20,15,22),fill=C['black'])

def goal(p):
    base(p);p.polygon([(3,20),(5,16),(17,16),(20,20)],fill=C['rock']);p.rectangle((8,7,15,18),fill=C['paper']);p.rectangle((6,5,17,8),fill=C['forest']);p.rectangle((9,1,14,4),fill=C['gold']);p.rectangle((10,2,13,3),fill=C['sun']);p.rectangle((10,10,12,13),fill=C['black'])

def trail(p):
    floor(p);p.rectangle((10,9,14,13),fill=C['gold']);p.rectangle((11,10,13,12),fill=C['sun'])
for name,fn in [('floor',floor),('rock',rock),('agent',agent),('lighthouse',goal),('trail',trail)]:icon(name,fn)
print('asset pixels generated',len(list(ROOT.glob('*.png'))))
