import importlib, inspect, pathlib, sys, tempfile, json
sys.path.insert(0, ".")
mod = importlib.import_module("test_hidden")
ok = fail = 0
for name, fn in inspect.getmembers(mod, inspect.isfunction):
    if not name.startswith("test_"): continue
    try:
        with tempfile.TemporaryDirectory() as d:
            fn(pathlib.Path(d)) if "tmp_path" in inspect.signature(fn).parameters else fn()
        ok += 1
    except Exception as e:
        fail += 1
print(json.dumps({"tests_ok": ok, "tests_fail": fail}))
