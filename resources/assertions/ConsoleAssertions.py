"""Demo-only bridge: execute one assertion and share its outcome with both outputs."""

from robot.api.deco import keyword, library
from robot.errors import ExecutionFailed
from robot.libraries.BuiltIn import BuiltIn


@library(scope="TEST", auto_keywords=False)
class ConsoleAssertions:
    def __init__(self):
        self._logger_ids = {}

    @keyword
    def capture_and_log_response(self, name, response):
        """Register the same response without making another HTTP call."""
        robot = BuiltIn()
        reporter_id = robot.run_keyword("Capture Response", name, response)
        logger_id = robot.run_keyword("Log Response", name, response)
        self._logger_ids[reporter_id] = logger_id
        return reporter_id

    @keyword
    def assert_and_log(self, request_id, label, assertion_keyword, *arguments):
        """Preserve the original Robot result and record it in the console."""
        robot = BuiltIn()
        logger_id = self._logger_ids[request_id]
        try:
            result = robot.run_keyword("Assert", request_id, label, assertion_keyword, *arguments)
        except ExecutionFailed as error:
            robot.run_keyword("Log Assertion Result", logger_id, label, "FAIL", str(error))
            raise
        robot.run_keyword("Log Assertion Result", logger_id, label, "PASS")
        return result
