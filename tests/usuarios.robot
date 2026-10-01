*** Settings ***
Documentation    Flujos de usuarios contra Demo Users API; un HTML por test.

Resource         ../resources/services/usuarios.resource
Resource         ../resources/assertions/usuarios.resource

Suite Setup      Esperar disponibilidad de la API
Test Setup       Preparar datos del test
Test Teardown    Limpiar usuarios creados


*** Test Cases ***
USR-001 Crear actualizar y eliminar usuario
    ${response}    ${request_id}=    Crear usuario    Angel Demo    ${TEST_EMAIL}    sales
    Verificar código HTTP    ${request_id}    ${response}    201
    VAR    ${user_id}    ${response.json()}[id]
    ${response}    ${request_id}=    Consultar usuario    ${user_id}
    Verificar código HTTP    ${request_id}    ${response}    200
    Verificar correo de usuario    ${request_id}    ${response}    ${TEST_EMAIL}
    ${response}    ${request_id}=    Buscar usuarios    sales    10
    Verificar código HTTP    ${request_id}    ${response}    200
    Assert And Log    ${request_id}    Verificar resultado de búsqueda
    ...    Should Not Be Empty    ${response.json()}[items]
    ${response}    ${request_id}=    Reemplazar usuario    ${user_id}    Angel Actualizado    ${TEST_EMAIL}
    Verificar código HTTP    ${request_id}    ${response}    200
    Verificar rol de usuario    ${request_id}    ${response}    support
    ${response}    ${request_id}=    Desactivar usuario    ${user_id}
    Verificar código HTTP    ${request_id}    ${response}    200
    Verificar usuario desactivado    ${request_id}    ${response}
    ${response}    ${request_id}=    Eliminar usuario    ${user_id}
    Verificar código HTTP    ${request_id}    ${response}    204
    ${response}    ${request_id}=    Consultar usuario    ${user_id}
    Verificar código HTTP    ${request_id}    ${response}    404

USR-002 Rechazar correo duplicado
    ${response}    ${request_id}=    Crear usuario    Demo Original    ${TEST_EMAIL}
    Verificar código HTTP    ${request_id}    ${response}    201
    ${response}    ${request_id}=    Crear usuario    Demo Duplicado    ${TEST_EMAIL}
    Verificar código HTTP    ${request_id}    ${response}    409

USR-003 Mostrar una assertion fallida
    [Tags]    expected-failure
    Set Case Metadata    test_id=USR-003    environment=demo
    ${response}    ${request_id}=    Crear usuario    Demo Fallido    ${TEST_EMAIL}    sales
    Verificar código HTTP    ${request_id}    ${response}    201
    Verificar rol de usuario    ${request_id}    ${response}    admin

USR-004 Escenario pendiente
    Skip    Carga de avatar fuera del alcance actual.
