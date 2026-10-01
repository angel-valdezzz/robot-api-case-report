*** Settings ***
Library    String
Library    RequestReporter


*** Keywords ***
Verificar datos del distribuidor
    [Documentation]    Completa las cinco validaciones y conserva FAIL si alguna falla.
    [Arguments]    ${request_id}    ${response}    ${tipo_distribuidor}    ${tipo_persona}
    VAR    ${distribuidor}    ${response.json()}
    Verificar campos del distribuidor    ${request_id}    ${distribuidor}    ${tipo_distribuidor}    ${tipo_persona}

Verificar campos del distribuidor
    [Documentation]    Assertions independientes: ejecuta todas y conserva los fallos.
    [Tags]    robot:continue-on-failure
    [Arguments]    ${request_id}    ${distribuidor}    ${tipo_distribuidor}    ${tipo_persona}
    Verificar tipo distribuidor    ${request_id}    ${distribuidor}    ${tipo_distribuidor}
    Verificar tipo persona de distribuidor    ${request_id}    ${distribuidor}    ${tipo_persona}
    Verificar RFC no vacío    ${request_id}    ${distribuidor}
    Verificar CURP no vacía    ${request_id}    ${distribuidor}
    Verificar folio generado    ${request_id}    ${distribuidor}

Verificar tipo distribuidor
    [Arguments]    ${request_id}    ${distribuidor}    ${esperado}
    Assert    ${request_id}    Verificar tipo distribuidor
    ...    Should Be Equal As Strings    ${distribuidor}[tipoDistribuidor]    ${esperado}

Verificar tipo persona de distribuidor
    [Arguments]    ${request_id}    ${distribuidor}    ${esperado}
    Assert    ${request_id}    Verificar tipo persona de distribuidor
    ...    Should Be Equal As Strings    ${distribuidor}[tipoPersona]    ${esperado}

Verificar RFC no vacío
    [Arguments]    ${request_id}    ${distribuidor}
    Assert    ${request_id}    Verificar RFC no vacío
    ...    Campo Debe Tener Contenido    ${distribuidor.get('rfc')}

Verificar CURP no vacía
    [Arguments]    ${request_id}    ${distribuidor}
    Assert    ${request_id}    Verificar CURP no vacía
    ...    Campo Debe Tener Contenido    ${distribuidor.get('curp')}

Campo Debe Tener Contenido
    [Documentation]    Rechaza campo ausente, null, vacío o solo espacios.
    [Arguments]    ${valor}
    Should Not Be Equal    ${valor}    ${NONE}    msg=El campo es null.
    ${texto}=    Convert To String    ${valor}
    ${texto}=    Strip String    ${texto}
    Should Not Be Empty    ${texto}    msg=El campo no tiene contenido.

Verificar código HTTP
    [Arguments]    ${request_id}    ${response}    ${esperado}
    Assert    ${request_id}    Verificar código HTTP
    ...    Should Be Equal As Integers    ${response.status_code}    ${esperado}

Verificar folio generado
    [Documentation]    Valida el folio del response body; no crea datos de resultado adicionales.
    [Arguments]    ${request_id}    ${distribuidor}
    Assert    ${request_id}    Verificar folio generado
    ...    Should Not Be Empty    ${distribuidor}[registration][folio]
