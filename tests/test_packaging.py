import importlib.util
import pathlib
import tempfile
import unittest
import zipfile
BASE=pathlib.Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('inspect_build',BASE/'tools/inspect_build.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
class PackageTests(unittest.TestCase):
    def test_missing_build_is_not_reported_pass(self):
        self.assertEqual(m.inspect('/path/not/existing.apk')['status'],'UNTESTED')
    def test_invalid_zip_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            path=pathlib.Path(tmp)/'bad.zip';path.write_bytes(b'not a zip')
            self.assertEqual(m.inspect(path)['status'],'FAIL')
    def test_zip_path_traversal_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            path=pathlib.Path(tmp)/'bad.zip'
            with zipfile.ZipFile(path,'w') as f:f.writestr('../escape.txt','bad')
            self.assertEqual(m.inspect(path)['status'],'FAIL')
