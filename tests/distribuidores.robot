*** Settings ***
Documentation       Ejemplo ejecutable con APICaseReporter y RequestsLibrary.
Resource            ../resources/distribuidores.resource
Resource            ../resources/validaciones.resource


*** Test Cases ***
DIST-002 Validar datos del distribuidor
    [Documentation]    Consulta un distribuidor y verifica su clasificación e identificación.
    [Tags]    api    distribuidores    DIST-002
    # Metadatos opcionales. El nombre y estado del caso los toma el listener.
    Set Case Metadata    case_id=DIST-002    environment=QA
    ...    data_row=2    distribuidor_id=1087

    ${token}=    Obtener token de acceso
    ${distribuidor}    ${request_id}=    Consultar distribuidor    ${token}    1087

    Verificar datos del distribuidor    ${request_id}    ${distribuidor}    AGENTE    FISICA

    # No hay Generate Report: el listener escribe este HTML en end_test.
