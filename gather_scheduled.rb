# coding: utf-8

require 'rubygems'
require 'clockwork'
include Clockwork

require_relative 'google_calendar'
require_relative 'arukuma_schedule'

handler do |job|
  arukuma = ArukumaSchedule.new
  cal = GoogleCalendar.new


  # カレンダー登録する日付のイベントを、一度削除する
  if arukuma.delible?
    events = cal.list_events_from_today
    cal.delete_events(events)

    puts "今日以降のイベントを削除しました"
  end


  # スクレイピング
  schedules = arukuma.list_events_from_today

  # カレンダー登録
  cal.insert_events(schedules)

  puts "今日以降のイベントを登録しました"
end

every(1.day, 'gather_arukuma')