# coding: utf-8

require 'date'
require "google/api_client"
require 'dotenv'


class GoogleCalendar

  attr_reader :client, :service
  def initialize
    Dotenv.load

    # .envファイルには設定済である前提なので、チェックは気持ち程度
    if ENV['GOOGLE_CLIENT_ID'].nil?
      raise StandardError
    end

    @client = Google::APIClient.new(application_name: 'arukumap',
                                    application_version: '1')

    @client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
    @client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
    @client.authorization.scope = ENV['GOOGLE_SCOPE']
    @client.authorization.refresh_token = ENV['GOOGLE_REFRESH_TOKEN']
    @client.authorization.access_token = ENV['GOOGLE_ACCESS_TOKEN']

    if @client.authorization.refresh_token && @client.authorization.expired?
      @client.authorization.fetch_access_token!
    end

    @service = @client.discovered_api('calendar', 'v3')
    @calendar_id = ENV['GOOGLE_CALENDAR_ID']
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