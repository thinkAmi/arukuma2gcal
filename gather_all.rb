# coding: utf-8

require 'date'
require_relative 'google_calendar'
require_relative 'arukuma_schedule'


arukuma = ArukumaSchedule.new
cal = GoogleCalendar.new

min_date = Date.new(Date.today.year, Date.today.month, 1)


if arukuma.delible?
  events = cal.list_events(min_date)

  cal.delete_events(events)
  puts "今月のイベントを削除しました"
end


# スクレイピング
schedules = arukuma.list_events(min_date)

# カレンダー登録
cal.insert_events(schedules)
puts "今月のイベントを登録しました"