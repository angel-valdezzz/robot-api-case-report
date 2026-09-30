*** Settings ***
Documentation    Librería real instalada desde PyPI; listener automático por caso.
Library          APICaseReporter
...              output_dir=${OUTPUT DIR}${/}cases
...              language=en
...              redact_headers=Authorization,Cookie,Set-Cookie
...              redact_body_fields=access_token,refresh_token,client_secret
