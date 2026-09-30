*** Settings ***
Documentation    Contrato de importación propuesto. APICaseReporter NO existe todavía.
Library          APICaseReporter
...              output_dir=${OUTPUT DIR}${/}cases
...              language=en
...              redact_headers=Authorization,Cookie,Set-Cookie
...              redact_body_fields=access_token,refresh_token,client_secret
...              WITH NAME    Report
