*** Settings ***
Documentation    Ejemplo ejecutable con RequestReporter y RequestsLibrary.

Library          RequestReporter
Resource         ../resources/services/distribuidores.resource
Resource         ../resources/assertions/distribuidores.resource


*** Test Cases ***
DIST-002 Validar datos del distribuidor
    [Documentation]    Consulta un distribuidor y verifica su clasificación e identificación.
    [Tags]    api    distribuidores    dist-002
    # Metadatos opcionales. El nombre y estado del caso los toma el listener.
    Set Case Metadata    case_id=DIST-002    environment=QA
    ...    data_row=2    distribuidor_id=1087

    ${token}=    Obtener token de acceso
    ${response}    ${request_id}=    Consultar distribuidor    ${token}    1087
    Verificar código HTTP    ${request_id}    ${response}    200

    Verificar datos del distribuidor    ${request_id}    ${response}    AGENTE    FISICA

    # No hay Generate Report: el listener escribe este HTML en end_test.
