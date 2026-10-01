*** Settings ***
Documentation    Ejemplo DataDriver con roles de usuario.

Library          DataDriver    file=../data/usuarios.csv    encoding=utf-8
Resource         ../resources/services/usuarios.resource
Resource         ../resources/assertions/usuarios.resource

Suite Setup      Esperar disponibilidad de la API
Test Setup       Preparar datos del test
Test Teardown    Limpiar usuarios creados
Test Template    Crear usuario y verificar rol


*** Test Cases ***
Usuario con rol ${role}    ${role}


*** Keywords ***
Crear usuario y verificar rol
    [Arguments]    ${role}
    ${response}    ${request_id}=    Crear usuario    Demo DDT    ${TEST_EMAIL}    ${role}
    Verificar código HTTP    ${request_id}    ${response}    201
    Verificar rol de usuario    ${request_id}    ${response}    ${role}
