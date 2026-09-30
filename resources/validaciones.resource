*** Settings ***
Library     String
Resource    reporter.resource


*** Keywords ***
Verificar datos del distribuidor
    [Documentation]    Completa las cuatro validaciones y conserva FAIL si alguna falla.
    [Tags]    robot:continue-on-failure
    [Arguments]    ${request_id}    ${distribuidor}    ${tipo_distribuidor}    ${tipo_persona}
    Verificar tipo distribuidor    ${request_id}    ${distribuidor}    ${tipo_distribuidor}
    Verificar tipo persona de distribuidor    ${request_id}    ${distribuidor}    ${tipo_persona}
    Verificar RFC no vacío    ${request_id}    ${distribuidor}
    Verificar CURP no vacía    ${request_id}    ${distribuidor}

Verificar tipo distribuidor
    [Arguments]    ${request_id}    ${distribuidor}    ${esperado}
    Check    ${request_id}    Verificar tipo distribuidor
    ...    Should Be Equal As Strings    ${distribuidor}[tipoDistribuidor]    ${esperado}

Verificar tipo persona de distribuidor
    [Arguments]    ${request_id}    ${distribuidor}    ${esperado}
    Check    ${request_id}    Verificar tipo persona de distribuidor
    ...    Should Be Equal As Strings    ${distribuidor}[tipoPersona]    ${esperado}

Verificar RFC no vacío
    [Arguments]    ${request_id}    ${distribuidor}
    Check    ${request_id}    Verificar RFC no vacío
    ...    Campo Debe Tener Contenido    ${distribuidor.get('rfc')}

Verificar CURP no vacía
    [Arguments]    ${request_id}    ${distribuidor}
    Check    ${request_id}    Verificar CURP no vacía
    ...    Campo Debe Tener Contenido    ${distribuidor.get('curp')}

Campo Debe Tener Contenido
    [Documentation]    Rechaza campo ausente, null, vacío o solo espacios.
    [Arguments]    ${valor}
    Should Not Be Equal    ${valor}    ${NONE}    msg=El campo es null.
    ${texto}=    Convert To String    ${valor}
    ${texto}=    Strip String    ${texto}
    Should Not Be Empty    ${texto}    msg=El campo no tiene contenido.
