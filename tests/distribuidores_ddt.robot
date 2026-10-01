*** Settings ***
Documentation    Alternativa DataDriver; ejecutar en lugar de la suite individual.

Library          RequestReporter
Library          DataDriver    file=${CURDIR}/../data/distribuidores.csv    encoding=utf-8
Resource         ../resources/services/distribuidores.resource
Resource         ../resources/assertions/distribuidores.resource

Test Template    Validar distribuidor desde datos


*** Test Cases ***
Validar distribuidor ${distribuidor_id}
    ${case_id}    ${distribuidor_id}    ${tipo_distribuidor}    ${tipo_persona}


*** Keywords ***
Validar distribuidor desde datos
    [Arguments]    ${case_id}    ${distribuidor_id}    ${tipo_distribuidor}    ${tipo_persona}
    Set Case Metadata    case_id=${case_id}    distribuidor_id=${distribuidor_id}
    ${token}=    Obtener token de acceso
    ${response}    ${request_id}=    Consultar distribuidor    ${token}    ${distribuidor_id}
    Verificar código HTTP    ${request_id}    ${response}    200
    Verificar datos del distribuidor
    ...    ${request_id}    ${response}    ${tipo_distribuidor}    ${tipo_persona}
