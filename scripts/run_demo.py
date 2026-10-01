"""Run both examples against a local fixture and verify actual per-case HTML."""

import argparse
import json
import re
import shutil
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Thread
from urllib.parse import parse_qs

from robot.api import ExecutionResult

ROOT = Path(__file__).resolve().parents[1]
TOKEN = "demo-token-not-a-real-credential"
SECRET = "demo-secret-not-a-real-credential"


class API(BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass

    def respond(self, status, body):
        payload = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_POST(self):
        form = parse_qs(self.rfile.read(int(self.headers.get("Content-Length", 0))).decode())
        if self.path != "/oauth/token":
            self.respond(404, {"error": "not found"})
        elif form.get("client_secret") != [SECRET]:
            self.respond(401, {"error": "invalid client"})
        else:
            self.respond(200, {"access_token": TOKEN, "token_type": "Bearer"})

    def do_GET(self):
        if self.headers.get("Authorization") != f"Bearer {TOKEN}":
            self.respond(401, {"error": "unauthorized"})
        elif self.path == "/v1/distribuidores/1087":
            body = json.loads((ROOT / "examples/response-distribuidor-1087.json").read_text())
            self.respond(200, body)
        elif self.path == "/v1/distribuidores/1042":
            self.respond(
                200,
                {
                    "tipoDistribuidor": "AGENTE",
                    "tipoPersona": "FISICA",
                    "rfc": "AAAA900101XXX",
                    "curp": "AAAA900101HDFXXX01",
                    "registration": {
                        "folio": "ALT-1042",
                        "office": {"name": "Centro", "active": True},
                    },
                    "contacts": [{"type": "email", "value": "demo@example.test"}],
                },
            )
        else:
            self.respond(404, {"error": "not found"})


def run_suite(server, suite, directory, expected_count, mode, console):
    output = ROOT / directory
    # Clear only these known demo output directories, never caller-selected paths.
    if output.exists():
        shutil.rmtree(output)
    process = subprocess.run(
        [
            sys.executable,
            "-m",
            "robot",
            "--outputdir",
            str(output),
            "--variable",
            f"BASE_URL:http://127.0.0.1:{server.server_port}",
            "--variable",
            f"LOGGER_MODE:{mode}",
            "--console",
            console,
            str(ROOT / "tests" / suite),
        ],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    transcript = process.stdout + process.stderr
    (output / "console.log").write_text(transcript, encoding="utf-8")
    print(transcript, end="")
    assert TOKEN not in transcript and SECRET not in transcript
    assert "HTTP 200" in transcript and "Verificar folio generado" in transcript
    tests = list(ExecutionResult(str(output / "output.xml")).suite.tests)
    assert len(tests) == expected_count
    assert process.returncode == 1, "Exactly one intentionally failing case is expected"
    reports = list((output / "cases").glob("*.html"))
    assert len(reports) == len(tests), "Each case must have its own HTML"
    seen = set()
    failing = None
    for path in reports:
        html = path.read_text()
        payload = re.search(
            r'<script type="application/json" id="case-data">(.*?)</script>',
            html,
            re.DOTALL,
        )
        assert payload, f"Missing payload in {path}"
        case = json.loads(payload[1])
        test = next(t for t in tests if t.name == case["name"])
        assert case["name"] not in seen
        seen.add(case["name"])
        if case["status"] == "SKIP":
            assert test.status == "SKIP" and not case["exchanges"]
            assert "fuera del alcance" in case["message"]
            continue
        is_fail = any("1087" in e["url"] for e in case["exchanges"])
        assert test.status == case["status"] == ("FAIL" if is_fail else "PASS")
        assert len(case["exchanges"]) == 2
        assert case["execution_errors"] == [], (
            "Assertion failures must not duplicate execution errors"
        )
        assert "Total assertions" in html and "section-failures" in html
        checks = [v for e in case["exchanges"] for v in e["validations"]]
        assert len(checks) == 8
        assert sum(v["status"] == "FAIL" for v in checks) == (2 if is_fail else 0)
        assert TOKEN not in html and SECRET not in html
        if is_fail:
            failing = path
    assert failing is not None
    return failing


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--logger-mode", choices=["summary", "failures", "full"], default="summary")
    parser.add_argument("--console", choices=["verbose", "quiet", "none"], default="verbose")
    options = parser.parse_args()
    server = ThreadingHTTPServer(("127.0.0.1", 0), API)
    worker = Thread(target=server.serve_forever, daemon=True)
    worker.start()
    try:
        failing = run_suite(
            server, "distribuidores.robot", "results", 3, options.logger_mode, options.console
        )
        run_suite(
            server,
            "distribuidores_ddt.robot",
            "results-ddt",
            2,
            options.logger_mode,
            options.console,
        )
        shutil.copyfile(failing, ROOT / "examples/report.html")
    finally:
        server.shutdown()
        server.server_close()
        worker.join()
    print(
        "Verified 5 standalone reports: 3 individual cases + 2 DataDriver cases. "
        "Expected failures preserved; credentials masked. examples/report.html generated."
    )


if __name__ == "__main__":
    main()
