require 'rubygems'
require 'active_support/all'
require 'mechanize'
require 'json'

class TempSensor
  def initialize(user, pass, device_id)
    @user = user
    @pass = pass
    @device_id = device_id

    @last_response = Time.now - 60.seconds

    @agent = Mechanize.new
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def setup
    @agent.get('https://mytotalconnectcomfort.com/portal')

    @agent.post('https://mytotalconnectcomfort.com/portal',
              'timeOffset' => '240',
              'UserName' => @user,
              'Password' => @pass,
              'RememberMe' => 'false')
  end

  def query
    data = JSON.parse(response.body)

    retval = {}
    retval['success'] = data['success']
    retval['device_live'] = data['deviceLive']
    retval['temp'] = data['latestData']['uiData']['DispTemperature']
    retval['heat_point'] = data['latestData']['uiData']['HeatSetpoint']
    retval['cool_point'] = data['latestData']['uiData']['CoolSetpoint']
    retval['device_id'] = data['latestData']['uiData']['DeviceID']
    retval['status'] = data['latestData']['uiData']['EquipmentOutputStatus']
    retval['fan_status'] = data['latestData']['fanData']['fanIsRunning']

    retval
  end

  private

  def response
    return @val if @last_response > 5.minutes.ago && @val

    @last_response = Time.now

    @val = @agent.get(
      "https://mytotalconnectcomfort.com/portal/Device/CheckDataSession/#{@device_id}?_=#{Time.now.to_i * 1000}",
      [],
      "https://mytotalconnectcomfort.com/portal/Device/Control/#{@device_id}",
      'X-Requested-With' => 'XMLHttpRequest'
    )
  end
end
