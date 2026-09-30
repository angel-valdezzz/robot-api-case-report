# Robot API Case Report — ejemplo de uso

Propuesta de una librería que genera **un HTML independiente por caso de prueba**,
con sus requests, responses, headers y validaciones. El archivo se puede adjuntar
individualmente a Jira sin incluir otros casos.

**Estado: diseño del contrato y ejemplo de integración. APICaseReporter y las
keywords Report.* son ficticios; la librería todavía no está implementada.**
Instalar las dependencias no hace ejecutables las suites, porque falta el reporter
y el dominio usado es ficticio. El boceto HTML sí se puede abrir para revisar la UI.

## Versiones

- Robot Framework **7.5**.
- RequestsLibrary **0.9.7**.
- DataDriver **1.11.2**, para la suite alternativa.
- Python **3.12** como entorno de referencia. “7.5” es la versión de Robot, no Python.

## Estructura

| Archivo | Propósito |
|---|---|
| tests/distribuidores.robot | Un caso con dos requests y siete validaciones. |
| resources/distribuidores.resource | POST para obtener token y GET para consultar distribuidor. |
| resources/validaciones.resource | Validaciones de negocio y su política de continuación. |
| resources/reporter.resource | Importación propuesta del reporter. |
| resources/config.resource | URL, timeout y credenciales ficticias. |
| tests/distribuidores_ddt.robot | Alternativa con DataDriver. |
| data/distribuidores.csv | Dos filas que generarían dos casos y dos HTML independientes. |
| examples/response-distribuidor-1087.json | Respuesta ficticia con dos errores de negocio. |
| examples/report.html | Boceto interactivo del reporte de un único caso. |

Ejecutar la suite individual o la alternativa DataDriver; ejecutar ambas repite
el escenario DIST-002.

## Suite simplificada

```robotframework
*** Settings ***
Resource    ../resources/distribuidores.resource
Resource    ../resources/validaciones.resource

*** Test Cases ***
DIST-002 Validar datos del distribuidor
    [Tags]    api    distribuidores    DIST-002
    Report.Set Case Metadata    case_id=DIST-002    environment=QA
    ...    data_row=2    distribuidor_id=1087

    ${token}=    Obtener token de acceso
    ${distribuidor}    ${request_id}=    Consultar distribuidor    ${token}    1087
    Verificar datos del distribuidor    ${request_id}    ${distribuidor}    AGENTE    FISICA
```

## Continuar solo en las validaciones

Las llamadas repetidas a `Run Keyword And Continue On Failure` se reemplazan por
una keyword de negocio que agrupa las cuatro comprobaciones:

```robotframework
Verificar datos del distribuidor
    [Tags]    robot:continue-on-failure
    [Arguments]    ${request_id}    ${distribuidor}    ${tipo_distribuidor}    ${tipo_persona}
    Verificar tipo distribuidor    ${request_id}    ${distribuidor}    ${tipo_distribuidor}
    Verificar tipo persona de distribuidor    ${request_id}    ${distribuidor}    ${tipo_persona}
    Verificar RFC no vacío    ${request_id}    ${distribuidor}
    Verificar CURP no vacía    ${request_id}    ${distribuidor}
```

El tag es nativo de Robot, existe desde 4.1 y aplica solo en este bloque. No es
recursivo: cada validación puede detenerse internamente si falla, y el grupo pasa
a la siguiente. El grupo termina FAIL si hubo errores y el test termina FAIL.
Si hubiera pasos después del grupo, no se ejecutarían tras su fallo. Los teardowns
conservan el comportamiento normal de Robot.

La adquisición del token, el HTTP esperado y el parsing de la consulta son pasos
previos sin ese tag: si fallan, no se ejecutan validaciones sobre datos inválidos.
No se necesita agregar una política de continuación al reporter ni a toda la suite.

## Acceso a diccionarios

Se usa `${distribuidor}[tipoDistribuidor]` y `${distribuidor}[tipoPersona]` para
claves obligatorias. Este acceso no necesita Collections ni Get From Dictionary;
la sintaxis genérica existe desde Robot Framework 3.1.

Para RFC y CURP se usa `${distribuidor.get('rfc')}` y `${distribuidor.get('curp')}`:
si no existe la clave, el valor es None y la keyword Campo Debe Tener Contenido
registra el fallo. También rechaza null, cadena vacía o solo espacios.

Si falta una clave obligatoria accedida con corchetes, Robot falla al resolver el
argumento, antes de ejecutar Report.Check. El futuro listener debe conservar ese
error en el caso, sin inventar una validación Check que no se ejecutó. Una validación
de esquema previa podría añadirse cuando el contrato de API lo requiera.

## Contrato del reporter propuesto

| Keyword ficticia | Argumentos | Comportamiento |
|---|---|---|
| Set Case Metadata | **metadata | Agrega metadatos opcionales al caso actual. |
| Capture HTTP Exchange | name, response | Copia request preparado y response; oculta secretos; devuelve un request_id local al caso. |
| Check | request_id, label, assertion_keyword, *args | Ejecuta la assertion real; registra PASS/FAIL, argumentos y error; propaga el fallo normal a Robot. |

Report.Check conserva las assertions reales de Robot. Solo agrega su registro al
request identificado. Para igualdad, el reporter puede interpretar argumentos y
mostrar Expected/Actual. Para la keyword propia Campo Debe Tener Contenido se
propone un adaptador que muestre Expected: non-empty value y Actual: valor recibido.
No se promete deducir reglas arbitrarias automáticamente.

La librería propuesta se importaría una sola vez y registraría su listener mediante
ROBOT_LIBRARY_LISTENER. En start_test crea el contexto; en end_test toma el estado
final de Robot y escribe el HTML. No requiere Begin Case, End Case, Generate Report
ni un --listener adicional.

El nombre, estado y duración vienen de Robot. El origen puede obtenerse automáticamente
y mostrarse de forma opcional. case_id, environment, data_row y distribuidor_id son
opcionales. DataDriver crea un contexto por test generado; no necesita reenviar la
fila manualmente para producir un HTML independiente.

Cada HTML incluiría únicamente los datos de ese caso y sus estilos/scripts, sin
dependencias de un reporte global. Los nombres se sanitizarían y las colisiones se
resolverían sin sobrescribir casos. El tamaño depende principalmente de los bodies.

## Resultado esperado

| Request | Resultado de las validaciones |
|---|---|
| POST /oauth/token | Código HTTP y token presente: 2 PASS. |
| GET /v1/distribuidores/1087 | HTTP, persona y CURP: 3 PASS; tipo distribuidor y RFC: 2 FAIL. |

Total: **2 requests, 5 PASS, 2 FAIL; caso FAIL**. La duración del boceto es ficticia.
Se captura el intercambio antes de verificar status o parsear JSON, para conservar
respuestas HTTP de error o no JSON. Un error de transporte sin response quedaría
en el error del caso por medio del listener; aún no se define una keyword para
registrar un intercambio sin respuesta.

## Boceto del reporte

Abrir `examples/report.html` en el navegador. La UI usa Request, Response, Headers
y Validations. Los nombres del caso y de sus comprobaciones siguen en español.

Headers ofrece Table / Raw y Copy para Request headers y Response headers por
separado. Copy respeta los valores ocultos. Si el navegador no permite clipboard,
se muestra texto seleccionable para copiar manualmente. Raw son líneas `Nombre: valor`,
no una captura byte a byte de la red. El logo provisional R / se eliminó.

El HTML incluido es un boceto con datos fijos, no un reporte generado por Robot.

## Ejecución futura

```bash
python -m pip install -r requirements.txt
# Instalar además APICaseReporter cuando exista y configurar un endpoint real.
robot --outputdir results tests/distribuidores.robot
# Alternativa:
robot --outputdir results-ddt tests/distribuidores_ddt.robot
```

Salida propuesta: `results/cases/DIST-002_Validar_datos_del_distribuidor.html`.
La redacción de secretos aplica al HTML del reporter; no configura el logging
independiente de Robot ni de RequestsLibrary.

## Verificación realizada

- Análisis sintáctico de las dos suites y los cuatro resources con Robot 7.5.
- Prueba aislada con assertions nativas: dos fallos en el grupo no impiden la
  tercera validación; el grupo y el test terminan FAIL. Un fallo previo detiene el flujo.
- Acceso con corchetes y `.get()` verificado con Robot 7.5.
- Requests de la UI, cuatro pestañas, Table/Raw y Copy comprobados con un DOM de prueba.

No se ejecutaron las suites completas ni se hicieron peticiones a un servidor:
el reporter sigue siendo un contrato ficticio. La UI no se verificó con un navegador real.

## Fuentes

- https://pypi.org/project/robotframework/7.5/
- https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#enabling-continue-on-failure-using-tags
- https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#accessing-list-and-dictionary-items
- https://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html
- https://github.com/Snooz82/robotframework-datadriver
