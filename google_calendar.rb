# coding: utf-8

require 'date'
require "google/api_client"
require 'yaml'



class GoogleCalendar

  attr_reader :client, :service
  def initialize
    unless File.exist?('.google-api.yaml')
      raise StandardError
    end

    unless File.exist?('arukuma_config.yaml')
      raise StandardError
    end

    oauth_yaml = YAML.load_file('.google-api.yaml')
    @client = Google::APIClient.new(application_name: 'arukumap', 
                                    application_version: '1')
    @client.authorization.client_id = oauth_yaml['client_id']
    @client.authorization.client_secret = oauth_yaml['client_secret']
    @client.authorization.scope = oauth_yaml['scope']
    @client.authorization.refresh_token = oauth_yaml['refresh_token']
    @client.authorization.access_token = oauth_yaml['access_token']

    if @client.authorization.refresh_token && @client.authorization.expired?
      @client.authorization.fetch_access_token!
    end

    @service = @client.discovered_api('calendar', 'v3')

    cal_yaml = YAML.load_file('arukuma_config.yaml')
    @calendar_id = cal_yaml['calendar_id']
  end


  # min_dateと同月内のイベントをリストアップ
  def list_events(min_date)
    # 既知の問題のため、日付(timeMin/timeMax)はUTCのISO8601形式で表現する
    # https://github.com/google/google-api-ruby-client/issues/38
    # http://blogaomu.com/2012/09/16/ruby-script-using-google-calendar-api
    last_day = Date.new(min_date.year, min_date.month, -1).day
    time_max = Time.new(min_date.year, min_date.month, last_day, 23, 59, 59).utc.iso8601
    time_min = Time.new(min_date.year, min_date.month, min_date.day).utc.iso8601

    # singleEventsパラメータが無い/falseの場合、
    # time_min/time_maxの値によっては正しい値が返ってこない
    # gemでなく、以下のページで試したとしても、正しい値が返ってこない
    # https://developers.google.com/google-apps/calendar/v3/reference/events/list?hl=ja
    #
    # また、maxResultsのデフォルト値の明記がなかったので、とりあえず300件をセットしておく
    # ただし、削除済のは取得しないよう、明示的にshowDeletedパラメータも追加しておく
    # http://stackoverflow.com/questions/20572978/hard-limit-on-maxresults-for-listing-events-in-google-calendar-api
    params = {
      calendarId: @calendar_id,
      timeMax: time_max,
      timeMin: time_min,
      showDeleted: false,
      singleEvents: true,
      maxResults: 300
    }

    result = @client.execute(api_method: @service.events.list,
                             parameters: params)
  end


  def list_events_from_today
    list_events(Date.today)
  end


  def delete_events(events)
    events.data['items'].each do |e|
      params = {
        calendarId: @calendar_id,
        eventId: e["id"]
      }

      @client.execute(api_method: @service.events.delete,
                      parameters: params)
    end
  end


  def insert_events(schedules)
    schedules.each do |s|
      event = {
        summary: s.event,
        description: s.place,
        location: s.location,
        start: {
          date: s.day
        },
        end: {
          date: s.day
        }
      }

      # tokenのリフレッシュを求められるかもしれないので、3回ほどチャレンジ
      3.times do |i|
        result = client.execute(api_method: service.events.insert,
                                parameters: { calendarId: @calendar_id },
                                body: JSON.dump(event),
                                headers: { 'Content-Type' => 'application/json'})

        break unless result.data['error']


        if i == 3
          puts result.data['error']
          raise StandardError
        else
          client.authorization.fetch_access_token!
        end
      end
    end
  end
end