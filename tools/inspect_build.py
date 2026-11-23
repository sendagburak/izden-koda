#!/usr/bin/env python3
"""Fail-closed export inspector. No native Android manifest parser, so require aapt."""
import json
import pathlib
import shutil
import subprocess
import sys
import zipfile

def inspect(path):
    p=pathlib.Path(path)
    if not p.is_file():
        return {'status':'UNTESTED','detail':'No exported artifact at supplied path','size':0}
    result={'size':p.stat().st_size,'path':str(p)}
    if p.suffix=='.apk':
        tool=shutil.which('aapt')
        if not tool: return dict(result,status='UNTESTED',detail='aapt unavailable; cannot verify binary AndroidManifest.xml')
        proc=subprocess.run([tool,'dump','permissions',str(p)],capture_output=True,text=True,check=False)
        if proc.returncode: return dict(result,status='FAIL',detail='aapt returned an error')
        if 'android.permission.INTERNET' in proc.stdout:
            return dict(result,status='FAIL',detail='Forbidden INTERNET permission present')
        return dict(result,status='PASS',detail='aapt permission check found no INTERNET permission')
    if p.suffix=='.zip':
        try:
            with zipfile.ZipFile(p) as zf:
                names=zf.namelist()
                if not names: return dict(result,status='FAIL',detail='Empty ZIP')
                if any('../' in n or n.startswith('/') for n in names):
                    return dict(result,status='FAIL',detail='Unsafe ZIP path')
            return dict(result,status='PASS',detail='Archive readable (NOT a gameplay test)')
        except zipfile.BadZipFile:
            return dict(result,status='FAIL',detail='Malformed ZIP')
    return dict(result,status='UNTESTED',detail='No inspector for this exported file type')
if __name__=='__main__':
    if len(sys.argv)!=2:
        print('Usage: inspect_build.py exported_file.apk|zip');sys.exit(2)
    item=inspect(sys.argv[1]); print(json.dumps(item,ensure_ascii=False,indent=2));sys.exit(0 if item['status']=='PASS' else 1)
