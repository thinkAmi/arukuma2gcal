# coding: utf-8

require 'open-uri'
require 'nokogiri'
require 'geocoder'
require 'date'

class Schedule

  attr_reader :day, :event, :place, :location
  def initialize(day, event, place, location)
    @day = day
    @event = event
    @place = place
    @location = location
  end
end


class ArukumaSchedule
  DEFAULT_LAT = '36.289167'
  DEFAULT_LNG = '137.648056'


  def initialize
    @doc = Nokogiri::HTML(open("http://arukuma.jp/schedule/"))
  end


  def delible?
    # アルクマスケジュールの左側が、システム日付と同月内のイベントになっていれば、削除可能
    # (注)
    # 月末になると翌月のカレンダーが左側に来ることがある
    # 登録はシステム日付と同月内のみなので、削除も同じようにする
    # また、クラスが「schedule aug」から変更となる可能性もあるが、その場合も削除しないようにする
    /\.([0-9]+)/ =~ @doc.xpath('//div[@class="schedule aug"]/h2').text
    $1 == Date.today.month.to_s
  end


  def insertable?(min_date, event_date, event)
    # 同月内で、min_day以降のイベントであれば、登録可能
    event_date.month == min_date.month && event_date.day >= min_date.day && !event.empty?
  end


  def list_events(min_date)
    schedules = []
    @doc.xpath('//div[@class="schedule aug"]/table/tr').drop(1).each do |item|

      # Google Geocode API を呼んでいるため、1秒間隔での動作とする
      sleep 1

      event_date = read_date(item)
      event = read_event(item)
      place = read_place(item)

      if insertable?(min_date, event_date, event)
        schedules << Schedule.new(event_date.strftime("%Y-%m-%d"), event, place, to_geo(place))
      end
    end

    schedules
  end


  def list_events_from_today()
    list_events(Date.today)
  end


  def read_date(item)
    mmdd = read_text(item, './td[1]')

    /([0-9]+).([0-9]+)/ =~ mmdd
    mm = $1
    dd = $2

    # タイムゾーンが日本(Tokyo)なので、Googleカレンダーに登録するときのStart.DayはUTCではなくJSTでOK
    result = Time.new(Date.today.year, mm, dd, 0)
  end


  def read_event(item)
    read_text(item, './td[2]')
  end


  def read_place(item)
    read_text(item, './td[3]')
  end


  def read_text(item, xpath)
    # Googleカレンダー登録時には不要な、改行と前後の空白を取り除く
    item.xpath(xpath).text.gsub(/(\r\n|\r|\n)/, '').strip
  end


  # Google Geocoding API でジオコーディング。
  # 変換できなければ、松本にある一番高い山のLAT/LNGを返す
  def to_geo(place)
    Geocoder.configure(lookup: :google, language: :ja, timeout: 5)

    geo_params = {
      countrycodes: 'ja'
    }

    begin
      result = Geocoder.search(place, params: geo_params)

      if result.size > 0
        result.first.coordinates.join(',')
      else
        DEFAULT_LAT + ',' + DEFAULT_LNG
      end
    rescue Exception => e
      puts $!
      DEFAULT_LAT + ',' + DEFAULT_LNG
    end
  end
end