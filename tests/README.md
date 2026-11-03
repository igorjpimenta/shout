# shout tests

One-command run from repo root:

```sh
bash tests/test_shout.sh
```

No extra services or dependencies (bash + Python 3 stdlib via `./shout`).
Covers: stdin uppercasing, file-arg uppercasing, --trim (stdin + file),
unknown-flag exit 2 + stderr, multi-file order, newline preservation.
