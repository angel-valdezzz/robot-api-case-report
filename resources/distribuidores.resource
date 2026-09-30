*** Settings ***
Library     RequestsLibrary
Resource    config.resource
Resource    reporter.resource


*** Keywords ***
Obtener token de acceso
    ${form}=    Create Dictionary
    ...    grant_type=client_credentials
    ...    client_id=${CLIENT_ID}
    ...    client_secret=${CLIENT_SECRET}
    ${headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded

    # expected_status=anything permite capturar también las respuestas 4xx/5xx.
    # La validación del código se hace después de registrar el intercambio.
    ${response}=    POST    ${BASE_URL}/oauth/token
    ...    data=${form}    headers=${headers}
    ...    expected_status=anything    timeout=${HTTP_TIMEOUT}
    ${request_id}=    Report.Capture HTTP Exchange    Obtener token    ${response}

    Report.Check    ${request_id}    Verificar código HTTP
    ...    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    Set Variable    ${response.json()}
    ${token}=    Set Variable    ${body.get('access_token', '')}
    Report.Check    ${request_id}    Verificar token presente
    ...    Should Not Be Empty    ${token}
    RETURN    ${token}

Consultar distribuidor
    [Arguments]    ${token}    ${distribuidor_id}
    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${token}
    ...    Accept=application/json
    ${response}=    GET    ${BASE_URL}/v1/distribuidores/${distribuidor_id}
    ...    headers=${headers}    expected_status=anything    timeout=${HTTP_TIMEOUT}
    ${request_id}=    Report.Capture HTTP Exchange    Consultar distribuidor    ${response}

    Report.Check    ${request_id}    Verificar código HTTP
    ...    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    Set Variable    ${response.json()}
    RETURN    ${body}    ${request_id}
