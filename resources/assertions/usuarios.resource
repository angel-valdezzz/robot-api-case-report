*** Keywords ***
Verificar código HTTP
    [Arguments]    ${request_id}    ${response}    ${expected}
    Assert And Log    ${request_id}    Verificar código HTTP
    ...    Should Be Equal As Integers    ${response.status_code}    ${expected}

Verificar rol de usuario
    [Arguments]    ${request_id}    ${response}    ${expected}
    Assert And Log    ${request_id}    Verificar rol de usuario
    ...    Should Be Equal    ${response.json()}[role]    ${expected}

Verificar correo de usuario
    [Arguments]    ${request_id}    ${response}    ${expected}
    Assert And Log    ${request_id}    Verificar correo de usuario
    ...    Should Be Equal    ${response.json()}[email]    ${expected}

Verificar usuario desactivado
    [Arguments]    ${request_id}    ${response}
    Assert And Log    ${request_id}    Verificar usuario desactivado
    ...    Should Be Equal    ${response.json()}[active]    ${FALSE}
