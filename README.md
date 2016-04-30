# integra2
Proyecto semestral del curso Taller de Integración | IIC3103 - Sección 1 | 1' 2016

Busca simular un sistema automático de compra-venta entre distintos grupos mediante APIs y una vista web que permite comprar con un sistema simulado tipo webpay.
## Installation
#### Prerequisites
Postgresql: sudo apt-get install postgresql postgresql-contrib libpq-dev

#### Configuration
Create user railsapp with password nicolas on postgresql

Ejecutar `rake db:create` // Si recibes el error "psql: FATAL: Peer authentication failed for user" --> http://stackoverflow.com/questions/17443379/psql-fatal-peer-authentication-failed-for-user-dev

## Usage
####IDs del grupo
Retorna el *id* de **grupo** mediante:<br />
`url/api/ids/grupo`<br />
El formato de retorno es:
```
{id: string}
```
Retorna el *id* de **banco** mediante:<br />
`url/api/ids/banco`<br />
El formato de retorno es:
```
{id: string}
```
Retorna el *id* del **almacen de recepción** mediante:<br />
`url/api/ids/almacenId`<br />
El formato de retorno es:
```
{id: string}
```
####Stock de un SKU
Retorna el stock de ese *sku* entre todos los almacenes de la empresa.<br />
`url/api/consultar/.:sku`<br />
El formato de retorno es:
```
{“stock”: int, “sku”: int}
```

## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History
TODO: Write history
## Credits
TODO: Write credits
## License
TODO: Write license
## Users & Passwords (CAREFUL!)
#### Postgresql
User: railsapp
Pass: nicolas
