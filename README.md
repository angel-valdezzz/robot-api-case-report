# Robot API Case Report — ejemplo ejecutable

Ejemplo real de **APICaseReporter 0.1.1**, instalado desde PyPI. Genera un HTML
independiente por caso con sus requests, responses, headers y validaciones.
Cada archivo funciona sin conexión y puede adjuntarse individualmente a Jira.

## Ejecutar la demostración

Requiere Python 3.12 o superior y Poetry 2.5.1. Las dependencias están fijadas
en `poetry.lock`; el ejemplo usa Poetry sin empaquetarse como librería.

```bash
python -m pip install poetry==2.5.1
poetry install
poetry run python scripts/run_demo.py
```

El script inicia una API ficticia en localhost, ejecuta ambas suites y verifica
el estado de cada caso, siete validaciones, aislamiento de los reportes y ocultación
de las credenciales ficticias. Se espera un caso fallido en cada suite: la demostración
comprueba esos fallos y termina correctamente solo si los resultados son los esperados.
No hace falta configurar un servidor externo ni credenciales reales.

| Suite | Resultado | HTML |
|---|---|---|
| Individual | DIST-002: FAIL, 5 validaciones PASS y 2 FAIL | `results/cases/` (1 archivo) |
| DataDriver | DIST-001: PASS; DIST-002: FAIL | `results-ddt/cases/` (2 archivos) |

Cada caso incluye dos requests: obtener token y consultar distribuidor.
Los fallos ficticios del distribuidor 1087 son tipo DIRECTO en lugar de AGENTE y RFC vacío.

**El script regenera `results/`, `results-ddt/` y `examples/report.html`.**
El HTML incluido en `examples/report.html` ahora es generado por Robot y la librería;
ya no es un boceto con datos incrustados manualmente.

## Estructura

| Archivo | Propósito |
|---|---|
| `tests/distribuidores.robot` | Caso individual con dos requests y siete validaciones. |
| `tests/distribuidores_ddt.robot` | Alternativa con DataDriver y dos casos independientes. |
| `resources/distribuidores.resource` | POST del token y GET de consulta con RequestsLibrary. |
| `resources/validaciones.resource` | Assertions de negocio y continuación nativa de Robot. |
| `resources/reporter.resource` | Importación real de APICaseReporter con alias  |
| `resources/config.resource` | URL por defecto y credenciales ficticias. |
| `data/distribuidores.csv` | Dos filas para DataDriver. |
| `scripts/run_demo.py` | API local y verificación de los reportes. |
| `examples/report.html` | Reporte real de DIST-002 para abrir en el navegador. |

## Integración

```robotframework
*** Settings ***
Resource    ../resources/distribuidores.resource
Resource    ../resources/validaciones.resource

*** Test Cases ***
DIST-002 Validar datos del distribuidor
    Set Case Metadata    case_id=DIST-002    environment=QA
    ...    data_row=2    distribuidor_id=1087
    ${token}=    Obtener token de acceso
    ${distribuidor}    ${request_id}=    Consultar distribuidor    ${token}    1087
    Verificar datos del distribuidor    ${request_id}    ${distribuidor}    AGENTE    FISICA
```

Las tres keywords de la librería son reales:

| Keyword | Función |
|---|---|
| `Set Case Metadata` | Agrega metadatos opcionales. |
| `Capture HTTP Exchange` | Captura el intercambio y devuelve un ID local al caso. |
| `Check` | Ejecuta una assertion de Robot, registra su resultado y propaga el fallo. |

El listener se registra al importar la librería. Escribe el HTML al terminar el caso;
no requiere Begin Case, End Case, Generate Report ni `--listener` adicional.

El tag `robot:continue-on-failure` se aplica solo al grupo de validaciones de negocio.
Permite completar las comprobaciones independientes y mantiene el caso en FAIL.
Token, HTTP esperado y parsing se verifican antes, sin esa continuación.

Las claves obligatorias usan `${distribuidor}[tipoDistribuidor]`; RFC y CURP usan
`.get()` para registrar también valores ausentes. La keyword propia
`Campo Debe Tener Contenido` rechaza None, cadena vacía y espacios.

## Usar un ambiente propio

```bash
poetry run robot --variable BASE_URL:https://tu-api.example --variable CLIENT_ID:tu-cliente --variable CLIENT_SECRET:tu-secreto --outputdir results tests/distribuidores.robot
```

Ajusta rutas, payloads y datos al contrato de tu servicio. Ejecuta la suite individual
**o** la alternativa DataDriver para no repetir DIST-002. Evita credenciales reales
en comandos compartidos; las variables de este repositorio son únicamente ficticias.

La ocultación de secretos aplica a los HTML del reporter. Robot y RequestsLibrary
mantienen sus propios logs. Headers ofrece Table/JSON y un icono de copia. La vista JSON tiene formato y
la copia contiene JSON indentado con los valores sensibles ocultos.

## Documentación y distribución

[Manual de usuario](https://angel-valdezzz.github.io/robotframework-api-case-reporter/) ·
[Referencia de keywords](https://angel-valdezzz.github.io/robotframework-api-case-reporter/keywords/) ·
[Ejemplo en vivo](https://angel-valdezzz.github.io/robotframework-api-case-reporter/examples/report.html) ·
[Paquete en PyPI](https://pypi.org/project/robotframework-api-case-reporter/)

La Action de este repositorio instala la versión publicada y ejecuta la misma
demostración. Sus artefactos contienen únicamente los tres HTML por caso.

## Sintaxis nativa de Robot Framework 7.5

Los diccionarios locales se crean con `VAR    &{headers}    Accept=application/json`.
Al pasarlos como objeto se usa `${headers}`, por ejemplo `headers=${headers}`.
Las asignaciones simples usan `VAR`; los retornos de keywords mantienen `${valor}=`.
Se conserva `RETURN`, acceso directo por clave y el tag nativo de continuación.
`config.resource` mantiene variables simples que pueden sobrescribirse desde CLI.
