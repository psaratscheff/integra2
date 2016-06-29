class DashboardController < ApplicationController
  def index
    @saldoCuenta = saldoCuenta()

    @abc = '123'
    url = "weqwsad"

    @fecha = Time.at(1467229112.to_i).to_datetime
    vieja = 16502400
    @actual = Time.now.to_i
    @fecha = saldoCuenta()

=begin
    result = HTTParty.post(url,
                  body:    {
                  fechaInicio: ,
                  fechaFin: asdasd,
                  id: aasdsad,
                }.to_json,
                  headers: {
                    'Content-Type' => 'application/json'
                })

    json = JSON.parse(result.body)
=end

  end

  def saldoCuenta()
    url = 'http://mare.ing.puc.cl/banco/cuenta/'+ $bancoid
    result = HTTParty.get(url,
              headers: {
                'Content-Type' => 'application/json'
              })
    json = JSON.parse(result.body)
    saldo = json[0]['saldo'].to_s
    return saldo
  end

end
