*** Settings ***
Documentation    Alternativa DataDriver; ejecutar en lugar de la suite individual.
Library          DataDriver    file=${CURDIR}/../data/distribuidores.csv    encoding=utf-8
Resource         ../resources/distribuidores.resource
Resource         ../resources/validaciones.resource
Test Template    Validar distribuidor desde datos


*** Test Cases ***
Validar distribuidor ${distribuidor_id}
    ${case_id}    ${distribuidor_id}    ${tipo_distribuidor}    ${tipo_persona}


*** Keywords ***
Validar distribuidor desde datos
    [Arguments]    ${case_id}    ${distribuidor_id}    ${tipo_distribuidor}    ${tipo_persona}
    Set Case Metadata    case_id=${case_id}    distribuidor_id=${distribuidor_id}
    ${token}=    Obtener token de acceso
    ${body}    ${request_id}=    Consultar distribuidor    ${token}    ${distribuidor_id}
    Verificar datos del distribuidor
    ...    ${request_id}    ${body}    ${tipo_distribuidor}    ${tipo_persona}
