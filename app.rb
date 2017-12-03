require './therm'
require 'sinatra'
require 'prometheus/client'
require 'prometheus/client/formats/text'

class App < Sinatra::Base
  configure do
    set :server, :puma
    set :bind, '0.0.0.0'
    set :port, 9100
  end

  def initialize
    super
    @registry = Prometheus::Client.registry

    @user = ENV['THERM_USER']
    @pass = ENV['THERM_PASSWORD']
    @device_id = ENV['THERM_DEVICE_ID']

    @sensor = TempSensor.new(@user, @pass, @device_id)

    @up = @registry.gauge(:therm_up, 'Is device responding')
    @device_live = @registry.gauge(:therm_deviceLive, 'Is device live')
    @temperature = @registry.gauge(:therm_temperature, 'Current temperature')
    @heat_point = @registry.gauge(:therm_heat_point, 'Current heat trigger point')
    @cool_point = @registry.gauge(:therm_cool_point, 'Current cool trigger point')

    @status = @registry.gauge(:therm_status, 'Current system status')
    @fan_status = @registry.gauge(:therm_fan_status, 'Current fan status')
  end

  get '/' do
    content_type :json

    @sensor.setup
    @sensor.query.to_json
  end

  get '/metrics' do
    @sensor.setup
    data = @sensor.query

    @up.set({ device_id: @device_id }, data['success'] ? 1 : 0)
    @device_live.set({ device_id: @device_id }, data['device_live'] ? 1 : 0)
    @temperature.set({ device_id: @device_id }, data['temp'])
    @heat_point.set({ device_id: @device_id}, data['heat_point'])
    @cool_point.set({ device_id: @device_id}, data['cool_point'])
    @status.set({ device_id: @device_id }, data['status'])
    @fan_status.set({ device_id: @device_id }, data['fan_status'] ? 1 : 0)

    Prometheus::Client::Formats::Text.marshal(@registry)
  end

  run! if app_file == $PROGRAM_NAME
end
