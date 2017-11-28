# ASP.NET Core 2 - "Live" Coding in 10 Schritten...

## Xubuntu vorbereiten

```bash
./xubuntu.sh
```

*Ein genauerer Blick in das Skript lohnt sich in jedem Fall.*

## Visual Studio Code

*Immer hilfreich: "Help -> Keyboard Shortcuts Reference"*

## .NET Core command-line interface (CLI) tools

```bash
dotnet new
```

*"Lists templates containing the specified name. If no name is specified, lists all templates."*

Ist aber über die Hilfe nicht vollständig dokumentiert, z.B. was

```bash
dotnet new mvc --auth Individual
```

bei den Beispielen bedeutet.

Die vollständige - wie überhaupt die gesamte relevante Dokumentation - findet sich unter [Microsoft Docs](https://docs.microsoft.com/en-us/):

[dotnet new command - .NET Core CLI | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-new?tabs=netcore2x)

## Dokumentation ASP.NET Core

### Einführung und Tutorials

[Introduction to ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/index)

### Neu in ASP.NET Core 1.0

[Introduction to ASP.NET Core (1.0)](https://docs.microsoft.com/en-us/aspnet/core/)

Wichtige Neuerungen in ASP.NET Core 1.0 sind u.a.:

* Tag Helpers
* JavaScriptServices
* Keine separate Web API mehr

### Neu in ASP.NET Core 2.0

[What's new in ASP.NET Core 2.0](https://docs.microsoft.com/en-us/aspnet/core/aspnetcore-2.0)

Wichtige Neuerungen in ASP.NET Core 2.0 sind u.a.:

* Razor Pages

## Demo-Projekt "ColorName"

### Schritt 0: GitHub

Unser Demo-Projekt selbst mit Commits für jeden einzelnen der folgenden Schritte findet sich unter:

[aspnet-core-2-demo](https://github.com/clxx/aspnet-core-2-demo.git)

Ein Beispiel für die Navigation zum Commit für Schritt 1:

```bash
git reset --hard @{u} && git clean -dfx && git reset --hard HEAD~19
```

### Schritt 1: Projekt vom Template erstellen

**Beginn mit der Vorlage "ASP.NET Core Empty".**

```bash
mkdir ColorName
cd $_
dotnet new web
```

Das neue Projekt `ColorName` in Visual Studio Code öffnen.

```bash
code .
```

***Debuggen. Resultat: "Hello World!" im Browser.***

### Schritt 2: MVC einrichten

#### Schritt 2.1: Konfiguration der Middleware

[ASP.NET Core Middleware Fundamentals](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware?tabs=aspnetcore2x)

Die Datei `ColorName/Startup.cs` öffnen.

In

```csharp
public void Configure(IApplicationBuilder app, IHostingEnvironment env)
```

das

```csharp
app.Run(async (context) =>
{
    await context.Response.WriteAsync("Hello World!");
});
```

durch

```csharp
app.UseStaticFiles();

app.UseMvcWithDefaultRoute();
```

ersetzen.

***Debuggen. Resultat: Exception - Built-in Dependency Injection, ist damit nicht mehr optional...***

#### Schritt 2.2: Dependency Injection

```csharp
public void ConfigureServices(IServiceCollection services)
```

erweitern:

```csharp
services.AddMvc();
```

***Debuggen. Resultat: 404, aber keine Exception mehr.***

### Schritt 3: Model erstellen

*Wir brauchen das Model zwar erst später, legen es aber bereits hier an, damit die Views kompilieren...*

Neuen Ordner `Models` anlegen.

Dort neue Datei `RgbColor.cs` erstellen:

```csharp
using System.ComponentModel.DataAnnotations;

namespace ColorName.Models
{
    public class RgbColor
    {
        [Required]
        [Range(0, 255)]
        public int Red { get; set; }

        [Required]
        [Range(0, 255)]
        public int Green { get; set; }

        [Required]
        [Range(0, 255)]
        public int Blue { get; set; }
    }
}
```

### Schritt 4: Home-Controller erstellen

Neuen Ordner `Controllers` anlegen.

Dort neue Datei `HomeController.cs` erstellen:

```csharp
using Microsoft.AspNetCore.Mvc;

namespace ColorName.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
```

**Bei den folgenden Schritten nicht aufhören zu debuggen.**

***Debuggen. Resultat: Internal Server Error - Exception, weil die View nicht gefunden wird.***

### Schritt 5: Index-View erstellen

#### Schritt 5.1: Index.cshtml mit Plain Text

Neue Ordner `Views/Home` anlegen.

Dort neue Datei `Index.cshtml` erstellen:

```csharp
Hello World!
```

***Reload der Seite im Browser mit F5. Resultat: "Hello World!"***

#### Schritt 5.2: Index.cshtml mit Razor View

Datei `Index.cshtml` ändern:

```csharp
@model ColorName.Models.RgbColor

@{
    ViewData["Title"] = "Color Name";
}

<div class="container" id="app">
    <div class="row justify-content-center">
        <div class="col align-self-center">
            <div class="card">
                @* jQuery Unobtrusive Validation needs this to be a form... *@
                <form class="card-body" id="color">
                    <h1 class="card-title">@ViewData["Title"]</h1>
                    <div class="form-group input-group">
                        <span class="input-group-addon">Red</span>
                        <input asp-for="Red"
                               type="text"
                               class="form-control"
                               v-on:keyup="validateForm"
                               v-model.lazy="red">
                    </div>
                    <div class="form-group input-group">
                        <span class="input-group-addon">Green</span>
                        <input asp-for="Green"
                               type="text"
                               class="form-control"
                               v-on:keyup="validateForm"
                               v-model.lazy="green">
                    </div>
                    <div class="form-group input-group">
                        <span class="input-group-addon">Blue</span>
                        <input asp-for="Blue"
                               type="text"
                               class="form-control"
                               v-on:keyup="validateForm"
                               v-model.lazy="blue">
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon">Name</span>
                        <input type="text"
                               class="form-control"
                               readonly
                               v-model="name">
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

@section scripts {
    <environment include="Development">
        <script src="~/debug/js/site.js"></script>
    </environment>
    <environment exclude="Development">
        <script src="~/site.min.js" asp-append-version="true"></script>
    </environment>
}
```

Direkt im Ordner `Views` neue Datei `_ViewImports.cshtml` erstellen:

```csharp
@addTagHelper *, Microsoft.AspNetCore.Mvc.TagHelpers
```

Direkt im Ordner `Views` neue Datei `_ViewStart.cshtml` erstellen:

```csharp
@{
    Layout = "_Layout";
}
```

Neuen Ordner `Views/Shared` anlegen.

Dort neue Datei `_Layout.cshtml` erstellen:

```csharp
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <title>@ViewData["Title"]</title>
    <base href="~/" />
    @* https://getbootstrap.com/docs/4.0/getting-started/introduction/ *@
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0-beta.2/css/bootstrap.min.css"
          integrity="sha256-QUyqZrt5vIjBumoqQV0jM8CgGqscFfdGhN+nVCqX0vc="
          crossorigin="anonymous" />
    <environment include="Development">
        <link rel="stylesheet" href="~/debug/css/site.css" />
    </environment>
    <environment exclude="Development">
        <link rel="stylesheet" href="~/site.min.css" asp-append-version="true" />
    </environment>
</head>
<body>
    @RenderBody()
    @* https://getbootstrap.com/docs/4.0/getting-started/introduction/ *@
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"
            integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
            crossorigin="anonymous">
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.13.0/umd/popper.min.js"
            integrity="sha256-pS96pU17yq+gVu4KBQJi38VpSuKN7otMrDQprzf/DWY="
            crossorigin="anonymous">
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0-beta.2/js/bootstrap.min.js"
            integrity="sha256-GIa8Vh3sfESnVB2CN3rYGkD/MklvMq0lmITweQxE1qU="
            crossorigin="anonymous">
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.17.0/jquery.validate.min.js"
            integrity="sha256-F6h55Qw6sweK+t7SiOJX+2bpSAa3b/fnlrVCJvmEj1A="
            crossorigin="anonymous">
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validation-unobtrusive/3.2.6/jquery.validate.unobtrusive.min.js"
            integrity="sha256-g1QKGxqsp+x5JkuN/JjHl96je2wztgS5Wo4h4c7gm9M="
            crossorigin="anonymous">
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.9/vue.min.js"
            integrity="sha256-GdIrqezgbUYuDyvVTXY2aB7O82eUby3pbR9Jb/e9ve0="
            crossorigin="anonymous">
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/axios/0.17.1/axios.min.js"
            integrity="sha256-A83FHt22LbSOPYN9dGs74h/J0jqc3TZapHUplf2uupI="
            crossorigin="anonymous">
    </script>
    @RenderSection("scripts", required: false)
</body>
</html>
```

***Nach einem Reload der Seite im Browser mit F5 sieht man nun die bereits teilweise gestylte Anwendung; ein Blick in die Developer Tools des Browsers verrät jedoch: sie findet wie erwartet die eigenen CSS- und JavaScript-Dateien noch nicht...***

### Schritt 6: CSS und JavaScript

#### Schritt 6.1: Anwendungs-CSS

Neue Ordner `ClientApp/css` anlegen.

Darin neue Datei `site.css` erstellen:

```css
html,
body,
.container,
.row {
    height: 100%;
}

.col {
    max-width:18rem;
}

h1 {
    font-size: 1.5rem;
}

.input-group-addon {
    min-width: 4.5rem;
}
```

#### Schritt 6.2: Anwendungs-JavaScript

Neuen Ordner `ClientApp/js` anlegen.

Darin neue Datei `site.js` erstellen:

```javascript
new Vue({
    el: '#app',
    data: {
        red: 0,
        green: 0,
        blue: 0,
        name: 'black'
    },
    watch: {
        red: function () { this.name = this.getName() },
        green: function () { this.name = this.getName() },
        blue: function () { this.name = this.getName() }
    },
    methods: {
        validateForm: function () {
            var form = $('#color');
            $.extend(form.validate().settings, {
                highlight: function (element) {
                    $(element).addClass('is-invalid');
                },
                unhighlight: function (element) {
                    $(element).removeClass('is-invalid');
                },
                errorElement: 'div',
                errorClass: 'form-group invalid-feedback',
                errorPlacement: function (error, element) {
                    error.insertAfter(element.closest('.input-group'));
                }
            });
            return form.valid();
        },
        getName: function () {
            if (!this.validateForm()) {
                return "Invalid..."
            }
            axios.get('/Color/Get', {
                params: {
                    red: this.red,
                    green: this.green,
                    blue: this.blue
                }
            }).then(response => {
                this.name = response.data;
            }).catch(error => {
                this.name = 'Error...';
            });
            return 'Computing...';
        }
    }
})
```

*Wir nutzen Vue.js im Demo-Projekt als MVVM-Framework, weil Angular oder React.js hier im Setup etwas komplexer wären und weil sie in den Templates TypeScript voraussetzen (Knockout als Alternative ist schon älter und weniger leistungsfähig).*

##### Exkurs: Validierung in ASP.NET Core 2 und Bootstrap 4

[Introduction to model validation in ASP.NET Core MVC](https://docs.microsoft.com/en-us/aspnet/core/mvc/models/validation)

```html
<div class="form-group">
    <label asp-for="ReleaseDate" class="col-md-2 control-label"></label>
    <div class="col-md-10">
        <input asp-for="ReleaseDate" class="form-control" />
        <span asp-validation-for="ReleaseDate" class="text-danger"></span>
    </div>
</div>
```

vs.

[Bootstrap Forms Validation](https://getbootstrap.com/docs/4.0/components/forms/#validation)

```html
<div class="col-md-6 mb-3">
    <label for="validationCustom03">City</label>
    <input type="text" class="form-control" id="validationCustom03" placeholder="City" required>
    <div class="invalid-feedback">Please provide a valid city.</div>
</div>
```

Deshalb ist das 

```javascript
$.extend(form.validate().settings, { ...
```

erforderlich...

***Debuggen. Die eigenen CSS- und JavaScript-Dateien werden immer noch nicht gefunden...***

### Schritt 7: Bundling und Minification

#### Schritt 7.1

Für die folgenden Schritte muss die `.gitignore` angepasst werden (Einkommentierung):

```text
# Uncomment if you have tasks that create the project's static files in wwwroot
wwwroot/
```

Falls das Verzeichnis `wwwroot` nicht mehr existiert (`dotnet new` legt es an, aber Git kann von sich aus keine leeren Verzeichnisse committen), muss es nun wieder angelegt werden.

*Mit "Ctrl+\`" das integrierte Terminal in Visual Studio Code anzeigen und dort den folgenden Befehl ausführen:*

```bash
mkdir wwwroot
```

Direkt im Root-Verzeichnis des Projekts eine neue Datei `bundleconfig.json` erstellen:

```json
[
    {
        "outputFileName": "wwwroot/site.min.css",
        "inputFiles": [
            "ClientApp/css/*.css"
        ]
    },
    {
        "outputFileName": "wwwroot/site.min.js",
        "inputFiles": [
            "ClientApp/js/*.js"
        ],
        "minify": {
            "enabled": true,
            "renameLocals": true
        },
        "sourceMap": false
    }
]
```

[Bundling and minification in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/client-side/bundling-and-minification)

*Mit "Ctrl+\`" das integrierte Terminal in Visual Studio Code anzeigen und dort den folgenden Befehl ausführen:*

```bash
dotnet add package BuildBundlerMinifier
```

*Die Referenz auf das neue Package wird in .NET Core übrigens direkt in der `*.csproj`-Datei hinterlegt - und nur noch dort!*

***Debuggen: Die eigenen CSS- und JavaScript-Dateien werden weiterhin nicht gefunden.***

#### Schritt 7.2

Wir ändern jetzt beispielsweise über "Debug -> Open Configurations" in der Datei `.vscode/launch.json` den Wert von `ASPNETCORE_ENVIRONMENT`:

```json
"ASPNETCORE_ENVIRONMENT": "Development"
```

zu

```json
"ASPNETCORE_ENVIRONMENT": "Production"
```

***Debuggen: Die eigenen, minifizierten CSS- und JavaScript-Dateien werden nun gefunden.***

#### Schritt 7.3

Wir machen die Änderung von `ASPNETCORE_ENVIRONMENT` in der Datei `.vscode/launch.json` wieder rückgängig:

```json
"ASPNETCORE_ENVIRONMENT": "Production"
```

zu

```json
"ASPNETCORE_ENVIRONMENT": "Development"
```

#### Schritt 7.4

Die Datei `ColorName/Startup.cs` öffnen und in

```csharp
public void Configure(IApplicationBuilder app, IHostingEnvironment env)
```

direkt unter dem

```csharp
app.UseStaticFiles();
```

ein

```csharp
if (env.IsDevelopment())
{
    app.UseStaticFiles(new StaticFileOptions()
    {
        FileProvider = new PhysicalFileProvider(Path.GetFullPath("ClientApp")),
        RequestPath = new PathString("/debug")
    });
}
```

ergänzen.

Erforderliche Usings:

```csharp
using System.IO;
using Microsoft.Extensions.FileProviders;
```

***Debuggen: Die eigenen, nicht minifizierten CSS- und JavaScript-Dateien werden nun auch in der "Development"-Umgebung gefunden. Eine Änderung der RGB-Werte führt jedoch noch immer zu einer 404, wie ein Blick in die Developer Tools des Browsers zeigt.***

### Schritt 8: Daten-Controller erstellen

Installation des "Windows Compatibility Pack" über .NET CLI. Dies ist ein optionaler Schritt zu Demonstrationszwecken - die gewünschte Funktionalität könnten wir in diesem Fall auch leicht selbst implementieren:

*Mit "Ctrl+\`" das integrierte Terminal in Visual Studio Code anzeigen und dort den folgenden Befehl ausführen:*

```bash
dotnet add package Microsoft.Windows.Compatibility --version 2.0.0-preview1-25914-04
```

Im Verzeichnis `Controllers` die Datei `ColorController.cs` anlegen:

```csharp
using System.Drawing;
using ColorName.Models;
using Microsoft.AspNetCore.Mvc;

namespace ColorName.Controllers
{
    public class ColorController : Controller
    {
        public IActionResult Get(RgbColor rgbColor)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var color = Color.FromArgb(rgbColor.Red, rgbColor.Green, rgbColor.Blue);

            return Content($"#{color.Name.Substring(2)}");
        }
    }
}
```

***Debuggen: Wenn man einen Breakpoint vor dem `return` setzt, kann man `drawingColor` übrigens auch im Debug Console Window untersuchen.***

### Schritt 9: Datenbank-Anbindung mit Entity Framework Core 2.0

#### Schritt 9.1

Im Verzeichnis `Models` die Datei `NamedColor.cs` anlegen:

```csharp
using System.ComponentModel.DataAnnotations;

namespace ColorName.Models
{
    public class NamedColor
    {
        [Key]
        public string Argb { get; set; }

        [Required]
        public string Name { get; set; }
    }
}
```

Dann im Verzeichnis `Models` die Datei `ColorNameContext.cs` anlegen:

```csharp
using Microsoft.EntityFrameworkCore;

namespace ColorName.Models
{
    public class ColorNameContext : DbContext
    {
        public ColorNameContext(DbContextOptions<ColorNameContext> options) : base(options)
        {
        }

        public DbSet<NamedColor> NamedColors { get; set; }
    }
}
```

Dann im Verzeichnis `Models` die Datei `ColorNameInitializer.cs` anlegen:

```csharp
using System.Collections.Generic;

namespace ColorName.Models
{
    public static class ColorNameInitializer
    {
        public static void Initialize(ColorNameContext colorNameContext)
        {
            // No migrations necessary any more for rapid prototyping/development...

            // https://docs.microsoft.com/en-us/ef/core/api/microsoft.entityframeworkcore.infrastructure.databasefacade

            colorNameContext.Database.EnsureDeleted();

            colorNameContext.Database.EnsureCreated();

            foreach (var namedColor in new[]
            {
                ("00ffff", "aqua"),
                ("000000", "black"),
                ("0000ff", "blue"),
                ("ff00ff", "fuchsia"),
                ("808080", "gray"),
                ("008000", "green"),
                ("00ff00", "lime"),
                ("800000", "maroon"),
                ("000080", "navy"),
                ("808000", "olive"),
                ("800080", "purple"),
                ("ff0000", "red"),
                ("c0c0c0", "silver"),
                ("008080", "teal"),
                ("ffffff", "white"),
                ("ffff00", "yellow")
            })
            {
                colorNameContext.NamedColors.Add(new NamedColor
                {
                    Argb = $"ff{namedColor.Item1}",
                    Name = namedColor.Item2
                });
            }

            colorNameContext.SaveChanges();
        }
    }
}
```

Zuletzt die `Main`-Methode in der Datei `Program.cs` modifizieren:

```csharp
public static void Main(string[] args)
{
    var host = BuildWebHost(args);

    using (var scope = host.Services.CreateScope())
    {
        var services = scope.ServiceProvider;
        var logger = services.GetRequiredService<ILogger<Program>>();
        try
        {
            ColorNameInitializer.Initialize(services.GetRequiredService<ColorNameContext>());
            logger.LogInformation("Successfully (re)created and seeded the database.");
        }
        catch (Exception exception)
        {
            logger.LogError(exception, "An error occurred while (re)creating and seeding the database.");
        }
    }

    host.Run();
}
```

Erforderliche Usings:

```csharp
using ColorName.Models;
using Microsoft.Extensions.DependencyInjection;
```

#### Schritt 9.2

Die Datei `Controllers/ColorController.cs` anpassen:

```csharp
using System.Drawing;
using System.Threading.Tasks;
using ColorName.Models;
using Microsoft.AspNetCore.Mvc;

namespace ColorName.Controllers
{
    public class ColorController : Controller
    {
        private readonly ColorNameContext _colorNameContext;

        public ColorController(ColorNameContext colorNameContext)
        {
            _colorNameContext = colorNameContext;
        }

        public async Task<IActionResult> Get(RgbColor rgbColor)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var color = Color.FromArgb(rgbColor.Red, rgbColor.Green, rgbColor.Blue);

            var namedColor = await _colorNameContext.NamedColors.FindAsync(color.Name);

            return Content(namedColor?.Name ?? $"#{color.Name.Substring(2)}");
        }
    }
}
```

Erforderliches Using:

```csharp
using System.Threading.Tasks;
```

*Wichtig sind hier u.a. das `async Task<IActionResult>`.*

#### Schritt 9.3

##### SQLite

Für die folgenden Schritte muss die `.gitignore` noch einmal erweitert werden:

```text
# SQLite files
*.db
```

*Mit "Ctrl+\`" das integrierte Terminal in Visual Studio Code anzeigen und dort den folgenden Befehl ausführen:*

```bash
dotnet add package Microsoft.EntityFrameworkCore.Sqlite
```

Nun die Datei `ColorName/Startup.cs` öffnen und in

```csharp
public void ConfigureServices(IServiceCollection services)
```

direkt über dem

```csharp
services.AddMvc();
```

ein

```csharp
services.AddDbContext<ColorNameContext>(options =>
    options.UseSqlite("Data Source=ColorName.db"));
```

einfügen.

Erforderliche Usings:

```csharp
using ColorName.Models;
using Microsoft.EntityFrameworkCore;
```

***Debuggen: Die Anwendung ist nun voll funktionsfähig und läuft mit einer SQLite-Datenbank.***

#### Schritt 9.4

##### SQL Server 2017 unter Linux mit Docker

*Vorab - die erforderlichen Änderungen sind minimal!*

*Wir brauchen kein `dotnet add package Microsoft.EntityFrameworkCore.SqlServer` auszuführen - dieses Paket ist bereits im `Microsoft.AspNetCore.All` Metapackage enthalten.*

Die Datei `ColorName/Startup.cs` öffnen.

Ganz oben in der Klasse den folgenden Konstruktor hinzufügen:

```csharp
private IConfiguration _configuration;

// There is Dependency Injection everywhere!
public Startup(IConfiguration configuration)
{
    _configuration = configuration;
}
```

und dann in

```csharp
public void ConfigureServices(IServiceCollection services)
```

das

```csharp
services.AddDbContext<ColorNameContext>(options =>
    options.UseSqlite("Data Source=ColorName.db"));
```

durch ein

```csharp
// https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?tabs=aspnetcore2x#commandline-configuration-provider
// E.g. 'dotnet run key1=value1'
// or '"args": ["db=mssql"],' in '.vscode/launch.json'.
services.AddDbContext<ColorNameContext>(options =>
{
    if (_configuration["db"] == "mssql")
    {
        options.UseSqlServer("Initial Catalog=ColorName;User Id=SA;Password=Passw0rd!");
    }
    else
    {
        options.UseSqlite("Data Source=ColorName.db");
    }
});
```

ersetzen.

Erforderliches Using:

```csharp
using Microsoft.Extensions.Configuration;
```

Damit SQL Server 2017 nun auch tatsächlich genutzt wird, ändern wir über "Debug -> Open Configurations" in der Datei `.vscode/launch.json` den Wert von

```json
"args": [],
```

in

```json
"args": ["db=mssql"],
```

*Docker starten (der Code findet sich auch in `xubuntu.sh`):*

```bash
sudo docker run \
-e 'ACCEPT_EULA=Y' \
-e 'MSSQL_SA_PASSWORD=Passw0rd!' \
-p 1401:1433 \
--name mssql \
--network='host' \
-d microsoft/mssql-server-linux:2017-latest

sudo docker kill mssql
sudo docker rm mssql
```

***Debuggen: Die Anwendung ist weiterhin voll funktionsfähig - nur läuft jetzt im Hintergrund ein SQL Server 2017 in Docker.***

#### Schritt 9.5

Über "Debug -> Open Configurations" in der Datei `.vscode/launch.json` die Änderungen für SQL Server 2017 wieder rückgängig machen:

```json
"args": ["db=mssql"],
```

zu

```json
"args": [],
```

ändern.

### Schritt 10: Deployment in Docker

Zunächst publishen wir unsere Anwendung.

*Mit "Ctrl+\`" das integrierte Terminal in Visual Studio Code anzeigen und dort den folgenden Befehl ausführen:*

```bash
dotnet publish -c release
```

Das Ergebnis findet sich dann in `ColorName/bin/release/netcoreapp2.0/publish/`.

Wir müssen nun nur noch ein Dockerfile dazu erstellen. Wenn man wie wir bereits kompiliert hat, ist das sehr einfach:

[Building Docker Images for .NET Core Applications](https://docs.microsoft.com/en-us/dotnet/core/docker/building-net-docker-images)

[ASP.NET Core Runtime Docker Image](https://hub.docker.com/r/microsoft/aspnetcore/)

[Dockerfile reference](https://docs.docker.com/engine/reference/builder/)

Ansonsten findet sich hier eine Vorlage:

[dotnet-docker-samples/aspnetapp/Dockerfile](https://github.com/dotnet/dotnet-docker-samples/blob/master/aspnetapp/Dockerfile)

Direkt im Verzeichnis `ColorName` eine neue Datei `Dockerfile` erstellen:

```text
FROM microsoft/aspnetcore
COPY bin/release/netcoreapp2.0/publish/ .
ENTRYPOINT ["dotnet", "ColorName.dll"]
```

Jetzt können wir das Image vom Dockerfile builden:

```bash
sudo docker build -t colorname .
sudo docker run -d -p 8000:80 --name mvc colorname

# http://localhost:8000/

sudo docker kill mvc
sudo docker rm mvc
```

***Die Anwendung selbst läuft jetzt komplett in Docker und ist über Port 8000 zu erreichen.***
