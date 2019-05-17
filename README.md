[![Gem Version](https://badge.fury.io/rb/yanapiri.svg)](https://rubygems.org/gems/yanapiri)
[![Build Status](https://travis-ci.org/uqbar-project/yanapiri.svg?branch=master)](https://travis-ci.org/uqbar-project/yanapiri)

# Yanapiri

![logo](https://user-images.githubusercontent.com/1585835/57146278-53838f00-6d9b-11e9-9875-56dc509e4943.png)


Yanapiri es un vocablo aymara que significa "ayudante" o "el que ayuda".

A partir de este humilde aporte, es también una aplicación de línea de comandos (CLI) para asistir a docentes en ciertas tareas relacionadas al manejo de entregas a través de [GitHub Classroom](https://classroom.github.com/).

## Instalación

Yanapiri funciona con Ruby, por lo cual es necesario instalarlo antes. Podés consultar cómo hacerlo en [la documentación oficial](https://www.ruby-lang.org/es/documentation/installation/).

Una vez que tu entorno Ruby esté funcionando, ejecutá lo siguiente:

```
gem install yanapiri
```

Luego, por única vez, deberás darle a `yanapiri` un access token de GitHub y una organización por defecto sobre la cual trabajar. Para ello, ejecutá el siguiente comando:

```
yanapiri setup
```

## Uso

Podés ver una lista de los comandos existentes ejecutando `yanapiri help`.
Un flujo de trabajo típico sería el siguiente:

```
yanapiri clonar entrega-1
yanapiri corregir entrega-1 --commit-base 326336a8ba771611 --fecha-limite "2019-05-01 23:59:59"
```

### Trabajando con más de una organización

Yanapiri soporta tres formas de configurar la organización:
* global, que se configura con `yanapiri setup`;
* local, que se configura con `yanapiri init`;
* por parámetro, que se configura con la opción `--orga`.

Para los casos en que se necesite trabajar regularmente con más de una organización (por ejemplo, si tenés varios cursos) conviene utilizar la configuración local.

Un ejemplo de estructura de directorios podría ser el siguiente:

```
entregas
├── une-objetos1
└── unlu-intro
```

Para escribir la configuración local, habría que ejecutar `yanapiri init` en cada uno de los subdirectorios.

## Releases

Utilizamos la gema [bump](https://github.com/gregorym/bump) para generar los releases, en conjunto con [gren](https://github.com/github-tools/github-release-notes) para actualizar la información en GitHub Releases.

Las versiones se nombran según la especificación [Semantic Versioning 2.0.0](https://semver.org/) y son publicadas automáticamente en [RubyGems](http://rubygems.org) gracias a [Travis](https://travis-ci.org).

Para publicar una nueva versión (un _patch_, en este ejemplo), hay que ejecutar lo siguiente:

```bash
rake bump:patch             # o bien bump:minor o bump:major
git push --follow-tags
gren r
```

## Agradecimientos

Gracias a [Elizabeth Arostegui](http://www.coloripop.com/), autora de la cholita que usamos como logo de Yanapiri. Podés ver otros íconos de esa gran colección entrando a su sitio [Cosmocollita](http://cosmocollita.com/).
