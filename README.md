# Yanapiri

## Instalación

Yanapiri funciona con Ruby, por lo cual es necesario instalarlo antes. Podés consultar cómo hacerlo en [la documentación oficial](https://www.ruby-lang.org/es/documentation/installation/).

Una vez que tu entorno Ruby esté funcionando, ejecutá lo siguiente:

```
gem install yanapiri
```

## Uso

Lo primero que tenés que hacer es ejecutar `yanapiri setup`, lo cual te va a preguntar con qué organización querés trabajar por defecto y te va a pedir un access token de un usuario que pueda pushear a esa organización.

Luego podrás ejecutar cualquiera de los demás comandos. Podés ver una lista ejecutando `yanapiri help`.
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/faloi/yanapiri.
